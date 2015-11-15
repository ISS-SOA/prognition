require 'sinatra/base'
require 'rack-flash'
require 'json'

require 'haml'
require 'chartkick'

require 'httparty'

require 'active_support'
require 'active_support/core_ext'

##
# Web application to track progress on Codecademy
class ApplicationController < Sinatra::Base
  use Rack::MethodOverride
  use Rack::Session::Pool
  use Rack::Flash

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure :production, :development do
    enable :logging
  end

  API_BASE_URI = 'http://cadetdynamo.herokuapp.com'
  API_VER = '/api/v3/'

  helpers do
    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end

    def cadet_api_url(resource)
      URI.join(API_BASE_URI, API_VER, resource).to_s
    end

    def date_in_open_range?(date, from: nil, til: nil)
      from_check = from ? from < date : true
      til_check = til ? date < til : true

      from_check && til_check
    end

    def date_count(badges, from: nil, til: nil)
      dates = Hash.new(0)
      badges.each { |badge| dates[Date.parse(badge['date'])] += 1 }
      from ||= dates.keys.min - 1
      til ||= dates.keys.max + 1

      (from..til).each do |date|
        dates[date] = 0 if (dates[date] == 0) # if date in range is not yet set
      end
      dates
    end

    def array_strip(str_arr)
      str_arr.map(&:strip).reject(&:empty?)
    end

    def error_send(url, msg)
      flash[:error] = msg
      redirect url
      halt 303        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    end
  end

  # WEB LAMBDAS
  get_root_route = lambda do
    redirect '/cadets'
  end

  get_cadets = lambda do
    if params[:username]
      @username = params[:username].strip
      @from_date = params[:from_date].blank? ? nil : Date.parse(params[:from_date])
      @til_date = params[:til_date].blank? ? nil : Date.parse(params[:til_date])

      begin
        @cadet = HTTParty.get cadet_api_url("cadet/#{@username}.json")
      rescue
        error_send '/', 'Could not access Codecademy – please try again later'
      end

      error_send '/cadets', "Could not find a Codecademy user named: #{@username}" \
        if @username && @cadet.nil?

      @cadet['badges'] = @cadet['badges'].select do |badge|
        date_in_open_range?(Date.parse(badge['date']), from: @from_date, til: @til_date)
      end

      error_send "/cadets?username=#{@username}", 'No badges found within those dates' \
        if @cadet['badges'].count == 0

      @dates = date_count(@cadet['badges'], from: @from_date, til: @til_date)
    end

    haml :cadet
  end

  get_tutorials_new = lambda do
    haml :tutorials
  end

  get_tutorials_id = lambda do
    begin
      @id = params[:id]

      if session[:results]
        @results = session[:results]
        session[:results] = nil
      else
        request_url = cadet_api_url "tutorials/#{@id}"
        options =  { headers: { 'Content-Type' => 'application/json' } }
        @results = HTTParty.get(request_url, options)
      end

      haml :tutorials
    rescue => e
      logger.info e
      error_send '/tutorials', 'Could not find results of previous query -- it may have been deleted'
    end
  end

  post_tutorials = lambda do
    # description = params[:description].strip
    # usernames = array_strip params[:usernames].split("\r\n")
    # badges = array_strip params[:badges].split("\r\n")
    form = TutorialForm.new(params)

    error_send back, "Following fields are required: #{form.errors.messages.keys.map(&:to_s).join(', ')}" \
      unless form.valid?
      # if (description.empty? || usernames.empty? || badges.empty?)

    # params_h = { description: description, usernames: usernames, badges: badges }

    # params_h[:deadline] = Date.parse(params[:deadline]) \
    #   unless params[:deadline].empty?

    # request_url = cadet_api_url 'tutorials'
    # options =  {  body: form.to_json,
    #               headers: { 'Content-Type' => 'application/json' } }
    # results = HTTParty.post(request_url, options)

    results = CheckTutorialFromAPI.new(cadet_api_url('tutorials'), form).call

    ## TODO: Check for unique username failures
    error_send back, 'Could not find usernames' if (results.code != 200)

    session[:results] = results
    flash[:notice] = 'You may bookmark this query to return later for updated results'
    # id = results.request.last_uri.path.split('/').last
    redirect "/tutorials/#{results.id}"
  end

  delete_tutorials = lambda do
    request_url = cadet_api_url "tutorials/#{params[:id]}"
    HTTParty.delete(request_url)
    flash[:notice] = 'Previous group search results deleted'
    redirect '/tutorials'
  end

  # WEB ROUTES
  get '/', &get_root_route
  get '/cadets/?', &get_cadets
  get '/tutorials/?', &get_tutorials_new
  get '/tutorials/:id', &get_tutorials_id
  post '/tutorials', &post_tutorials
  delete '/tutorials/:id', &delete_tutorials
end
