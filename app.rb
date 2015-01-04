require 'sinatra/base'
require 'json'

require 'haml'
require 'sinatra/flash'
require 'chartkick'

require 'httparty'

##
# Web application to track progress on Codecademy
class Prognition < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  configure :production, :development do
    enable :logging
  end

  configure :development do
    set :session_secret, "something"    # ignore if not using shotgun in development
  end

  API_BASE_URI = 'http://cadetservice.herokuapp.com'
  API_VER = '/api/v2/'

  helpers do
    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end

    def api_url(resource)
      URI.join(API_BASE_URI, API_VER, resource).to_s
    end

    def date_count(badges)
      dates = Hash.new(0)
      badges.each { |badge| dates[Date.parse(badge['date'])] += 1 }
      (dates.keys.min..dates.keys.max).each do |date|
         if dates[date] == 0
           dates[date] = 0
         end
      end
      dates
    end
  end

  get '/' do
    haml :home
  end

  get '/cadet' do
    @username = params[:username]
    if @username
      redirect "/cadet/#{@username}"
      return nil
    end

    haml :cadet
  end

  get '/cadet/:username' do
    @username = params[:username]
    @cadet = HTTParty.get api_url("cadet/#{@username}.json")
    @dates = date_count(@cadet['badges'])

    if @username && @cadet.nil?
      flash[:notice] = "user #{@username} not found" if @cadet.nil?
      redirect '/cadet'
      return nil
    end

    haml :cadet
  end

  get '/tutorials' do
    @action = :create
    haml :tutorials
  end

  post '/tutorials' do
    request_url = "#{API_BASE_URI}/api/v2/tutorials"
    usernames = params[:usernames].split("\r\n")
    badges = params[:badges].split("\r\n")
    params_h = {
      usernames: usernames,
      badges: badges
    }

    options =  {  body: params_h.to_json,
                  headers: { 'Content-Type' => 'application/json' }
               }

    result = HTTParty.post(request_url, options)

    if (result.code != 200)
      flash[:notice] = 'usernames not found'
      redirect '/tutorials'
      return nil
    end

    id = result.request.last_uri.path.split('/').last
    session[:result] = result.to_json
    session[:usernames] = usernames
    session[:badges] = badges
    session[:action] = :create
    redirect "/tutorials/#{id}"
  end

  get '/tutorials/:id' do
    if session[:action] == :create
      session[:action] = nil
      @results = JSON.parse(session[:result])
      @usernames = session[:usernames]
      @badges = session[:badges]
    else
      request_url = "#{API_BASE_URI}/api/v2/tutorials/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      result = HTTParty.get(request_url, options)
      @results = result
    end

    @id = params[:id]
    @action = :update
    haml :tutorials
  end

  delete '/tutorials/:id' do
    request_url = "#{API_BASE_URI}/api/v2/tutorials/#{params[:id]}"
    result = HTTParty.delete(request_url)
    flash[:notice] = 'record of tutorial deleted'
    redirect '/tutorials'
  end
end
