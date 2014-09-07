require 'sinatra/base'
require 'codebadges'
require 'haml'
require 'json'

class CodecadetApp < Sinatra::Base
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
    # CodeBadges::CodecademyBadges.get_badges(params[:username]).to_json
    badges_array = []
    badges_hash = CodeBadges::CodecademyBadges.get_badges(params[:username])
    badges_hash.each_with_index do |(k, v), _|
      badges_array << { k => v }
    end
    badges_array.to_json
  end

end
