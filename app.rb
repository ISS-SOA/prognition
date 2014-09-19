require 'sinatra/base'
require 'codebadges'
require 'haml'
require 'json'

class CodecadetApp < Sinatra::Base
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

    def check_badges(username, badges)
      badges_found = CodeBadges::CodecademyBadges.get_badges(username).keys
    end
  end

  get '/' do
    redirect to('/cadet')
  end

  get '/cadet' do
    haml :home
  end

  get '/cadet/:username' do
    @badges_found = CodeBadges::CodecademyBadges.get_badges(params[:username])
    haml :result
  end

  post '/result' do
    redirect to("/cadet/#{params[:username]}")
  end

  get '/checkbadges' do
    haml :check
  end

  post '/checkbadges' do
    @check_info = {}
    usernames = params[:usernames].split("\r\n")
    badges = params[:badges].split("\r\n")

    usernames.each do |username|
      badges_found = CodeBadges::CodecademyBadges.get_badges(username).keys
      @check_info[username] = \
        badges.select { |badge| !badges_found.include? badge }
    end

    haml :check_result
  end

  get '/api/v1/cadet/:username.json' do
    content_type :json
    refactor.to_json
  end

end
