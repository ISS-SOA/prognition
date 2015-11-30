ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'watir-webdriver'
require 'headless'
require 'page-object'

Dir.glob('./{helpers,controllers,forms,services}/*.rb').each { |file| require file }
Dir.glob('./spec/pages/*.rb').each { |file| require file }

include Rack::Test::Methods

def app
  ApplicationController
end
