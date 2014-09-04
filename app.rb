require 'sinatra/base'
require 'codebadges'
require 'haml'

class CodecadetApp < Sinatra::Base
  get '/' do
    haml :home
  end
end
