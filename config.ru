$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra/base'
require './app_controller'

controllers = Dir.glob('./{controllers}/*.rb')
controllers.each { |file| require file }

AppController.controllers.each do |c|
  map("/#{c}") { run Module.const_get("#{c.capitalize}Controller".to_sym) } 
end #each 
