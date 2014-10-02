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
  end

  get '/' do
    redirect to('/cadet')
  end

  get '/cadet' do
    haml :home
  end

  get '/cadet/:username' do
    begin
      @badges_found = CodeBadges::CodecademyBadges.get_badges(params[:username])
      @dates = count_per_day(@badges_found)
      haml :result
    rescue OpenURI::HTTPError => _
      flash[:notice] = 'There is a Missing Username.'
      redirect to('/cadet')
    end
  end

  post '/result' do
    redirect to("/cadet/#{params[:username]}")
  end

  get '/check' do
    haml :check
  end

  get '/api/v1/cadet/:username.json' do
    content_type :json
    refactor.to_json
  end

  post '/api/v1/check' do
    content_type :json
    usernames = params[:usernames].split("\r\n")
    badges = params[:badges].split("\r\n")
    check_badges(usernames, badges).to_json
  end
end
