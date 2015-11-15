# \ -s puma

Dir.glob('./{helpers,controllers,forms,services}/*.rb').each { |file| require file }
run ApplicationController
