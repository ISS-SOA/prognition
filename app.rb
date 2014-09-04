require 'sinatra/base'
require 'codebadges'
require 'haml'

class CodecadetApp < Sinatra::Base
  get '/' do
    haml :home
  end

  post '/result' do
    @username = params[:username]
    @badges_found = CodeBadges::CodecademyBadges.get_badges(@username)
    haml :result
  end
end
