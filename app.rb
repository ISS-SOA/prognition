require 'sinatra/base'
require 'codebadges'
require 'haml'
require 'json'
require 'sinatra/flash'
require 'chartkick'

class CodecadetApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  helpers do
    def refactor
      badges_after = {
        'id'      => params[:username],
        'type'    => 'cadet',
        'badges'  => []
      }

      CodeBadges::CodecademyBadges.get_badges(params[:username]).each do |title, date|
        badges_after['badges'].push('id' => title, 'date' => date)
      end
      badges_after
    end

    def check_badges(usernames, badges)
      @check_info = {}
      usernames.each do |username|
        badges_found = CodeBadges::CodecademyBadges.get_badges(username).keys
        @check_info[username] = \
          badges.select { |badge| !badges_found.include? badge }
      end
      @check_info
    end

    def count_per_day(badges_info)
      dates = Hash.new(0)
      badges_info.values.each do |date|
        if dates.keys.include? date
          dates[date] += 1
        else
          dates[date] = 1
        end
      end
      dates
    end

    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end
  end

  get '/' do
    haml :home
  end

  get '/user' do
    haml :user
  end

  get '/user/:username' do
    begin
      @badges_found = CodeBadges::CodecademyBadges.get_badges(params[:username])
      @dates = count_per_day(@badges_found)
      haml :chart, :layout => false
    rescue OpenURI::HTTPError => _
      flash[:notice] = 'There is a Missing Username.'
      redirect to('/user')
    end
  end

  post '/result' do
    redirect to("/user/#{params[:username]}")
  end

  get '/group' do
    haml :group
  end

  get '/api/v1/cadet/:username.json' do
    content_type :json
    refactor.to_json
  end

  post '/api/v1/group' do
    content_type :json
    usernames = params[:usernames].split("\r\n")
    badges = params[:badges].split("\r\n")
    check_badges(usernames, badges).to_json
  end

  post '/api/v1/user' do
    content_type :json
    badges_found = CodeBadges::CodecademyBadges.get_badges(params[:username])
    badges_found.to_json
  end
end
