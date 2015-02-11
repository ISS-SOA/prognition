require 'sinatra/base'
require 'json'

require 'haml'
require 'chartkick'

require 'httparty'

require 'active_support'
require 'active_support/core_ext'

##
# Web application to track progress on Codecademy
class Prognition < Sinatra::Base
  use Rack::Session::Pool
  use Rack::MethodOverride

  configure :production, :development do
    enable :logging
  end

  configure :development do
    #set :session_secret, "something"    # ignore if not using shotgun in development
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

    def date_in_range?(date, from: nil, til: nil)
      from_check = from ? from < date : true
      til_check = til ? date < til : true

      from_check && til_check
    end

    def date_count(badges, from: nil, til: nil)
      dates = Hash.new(0)
      badges.each { |badge| dates[Date.parse(badge['date'])] += 1 }
      from ||= dates.keys.min - 1
      til  ||= dates.keys.max + 1

      (from..til).each do |date|
         if dates[date] == 0          # if date in range is not yet set
           dates[date] = 0
         end
      end
      dates
    end

    def array_strip(str_arr)
      str_arr.map(&:strip).reject(&:empty?)
    end

    def error_send(url, msg)
      session[:flash_error] = msg
      redirect url
      halt 303        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    end
  end

  get '/' do
    redirect '/cadets'
  end

  get '/cadets/?' do
    @username = params[:username]
    if @username
      unless params[:from_date].nil? || params[:from_date].empty?
        from_date = Date.parse params[:from_date]
        from_query = "?from_date=#{from_date}"
      end

      redirect "/cadets/#{@username}#{from_query}"
      return nil
    end

    haml :cadet
  end

  get '/cadets/:username' do
    @username = params[:username].strip
    from_date = params[:from_date] ? Date.parse(params[:from_date]) : nil
    til_date = params[:until_date] ? Date.parse(params[:until_date]) : nil

    begin
      @cadet = HTTParty.get cadet_api_url("cadet/#{@username}.json")
    rescue
      error_send back, "Could not access Codecademy – please try again later"
    end

    error_send back, "Could not find a Codecademy user named: #{@username}" \
      if @username && @cadet.nil?

    @cadet['badges'] = @cadet['badges'].select do |badge|
      date_in_range?(Date.parse(badge['date']), from: from_date, til: til_date)
    end

    error_send "/cadets/#{@username}", "No badges found within those dates" \
      if @cadet['badges'].count == 0

    @dates = date_count(@cadet['badges'], from: from_date, til: til_date)
    haml :cadet
  end

  get '/tutorials' do
    haml :tutorials
  end

  post '/tutorials' do
    description = params[:description].strip
    usernames = array_strip params[:usernames].split("\r\n")
    badges = array_strip params[:badges].split("\r\n")

    error_send back, 'All fields are required' \
      if (description.empty? || usernames.empty? || badges.empty?)

    request_url = cadet_api_url 'tutorials'
    params_h = {description: description, usernames: usernames, badges: badges}
    options =  {  body: params_h.to_json,
                  headers: { 'Content-Type' => 'application/json' } }
    results = HTTParty.post(request_url, options)

    error_send back, 'usernames not found' if (results.code != 200)

    session[:results] = results.to_json

    id = results.request.last_uri.path.split('/').last
    session[:flash_notice] = 'You may bookmark this query to return later for updated results'
    redirect "/tutorials/#{id}"
  end

  get '/tutorials/:id' do
    begin
      @id = params[:id]

      if session[:results]
        @results = JSON.parse session[:results]
        session[:results] = nil
      else
        request_url = cadet_api_url "tutorials/#{@id}"
        options =  { headers: { 'Content-Type' => 'application/json' } }
        @results = HTTParty.get(request_url, options)
      end

      haml :tutorials
    rescue
      error_send '/tutorials', 'Could not find results of previous query -- it may have been deleted'
    end
  end

  # put '/tutorials/:id' do
  #   begin
  #     @id = params[:id]
  #       request_url = cadet_api_url "tutorials/#{@id}"
  #       options =  { headers: { 'Content-Type' => 'application/json' } }
  #       @results = HTTParty.put(request_url, options)
  #     end
  #
  #     haml :tutorials
  #   rescue
  #     session[:flash_error] = 'Sorry -- we could not update that query'
  #     redirect "/tutorials/#{@id}"
  #   end
  # end

  delete '/tutorials/:id' do
    request_url = cadet_api_url "tutorials/#{params[:id]}"
    result = HTTParty.delete(request_url)
    session[:flash_notice] = 'Previous group search results deleted'
    redirect '/tutorials'
  end
end
