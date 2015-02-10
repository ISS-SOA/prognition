require 'sinatra/base'
require 'json'

require 'haml'
require 'chartkick'

require 'httparty'

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

    def array_strip(str_arr)
      str_arr.map(&:strip).reject(&:empty?)
    end
  end

  get '/' do
    redirect '/cadet'
  end

  get '/cadet/?' do
    @username = params[:username]
    if @username
      redirect "/cadet/#{@username}"
      return nil
    end

    haml :cadet
  end

  get '/cadet/:username' do
    @username = params[:username].strip
    begin
      @cadet = HTTParty.get cadet_api_url("cadet/#{@username}.json")
    rescue
      @cadet = nil
    end

    if @username && @cadet.nil?
      session[:flash_error] = "Could not find Codecademy user: #{@username}" if @cadet.nil?
      redirect '/cadet'
      return nil
    end

    @dates = date_count(@cadet['badges'])
    haml :cadet
  end

  get '/tutorials' do
    haml :tutorials
  end

  post '/tutorials' do
    description = params[:description].strip
    usernames = array_strip params[:usernames].split("\r\n")
    badges = array_strip params[:badges].split("\r\n")

    if (description.empty? || usernames.empty? || badges.empty?)
      session[:flash_error] = 'All fields are required'
      redirect '/tutorials'
      return
    end

    request_url = cadet_api_url 'tutorials'
    params_h = {description: description, usernames: usernames, badges: badges}
    options =  {  body: params_h.to_json,
                  headers: { 'Content-Type' => 'application/json' } }
    results = HTTParty.post(request_url, options)

    if (results.code != 200)
      session[:flash_error] = 'usernames not found'
      redirect '/tutorials'
      return nil
    end

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
      session[:flash_error] = 'Could not find results of previous query -- it may have been deleted'
      redirect '/tutorials'
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
