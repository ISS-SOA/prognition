# \ -s puma

Dir.glob('./{helpers,controllers,services}/*.rb').each { |file| require file }
run ApplicationController
