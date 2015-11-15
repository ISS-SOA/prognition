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
  helpers ApplicationHelpers

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure :production, :development do
    enable :logging
  end

  # WEB LAMBDAS
  get_root_route = lambda do
    redirect '/cadets'
  end

  get_cadets = lambda do
    if params[:username]
      @username = params[:username].strip
      @from_dt = params[:from_date].blank? ? nil : Date.parse(params[:from_date])
      @til_dt = params[:til_date].blank? ? nil : Date.parse(params[:til_date])

      begin
        @cadet = HTTParty.get cadet_api_url("cadet/#{@username}.json")
      rescue
        error_send '/', 'Could not access Codecademy – please try again later'
      end

      error_send '/cadets', "Could not find Codecademy user: #{@username}" \
        if @username && @cadet.nil?

      @cadet['badges'] = @cadet['badges'].select do |badge|
        date_in_range?(Date.parse(badge['date']), from: @from_dt, til: @til_dt)
      end

      error_send "/cadets?username=#{@username}", 'No badges within dates' \
        if @cadet['badges'].count == 0

      @dates = date_count(@cadet['badges'], from: @from_dt, til: @til_dt)
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
      error_send '/tutorials', 'Could not find query -- perhaps it was deleted?'
    end
  end

  post_tutorials = lambda do
    form = TutorialForm.new(params)
    error_send(back, 'Following fields are required: ' \
                     "#{form.errors.messages.keys.map(&:to_s).join(', ')}") \
      unless form.valid?

    results = CheckTutorialFromAPI.new(cadet_api_url('tutorials'), form).call
    error_send back, 'Could not find usernames' if (results.code != 200)

    session[:results] = results
    flash[:notice] = 'You may bookmark this query and return later for updates'
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
