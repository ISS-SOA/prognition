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

  get '/api/v1/cadet/:username.json' do
    content_type :json
    refactor.to_json
  end

end
