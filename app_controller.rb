require 'sinatra/base'
require 'json'
require 'yaml'
require "em-synchrony"
require "em-synchrony/mysql2"
require "em-synchrony/activerecord"
require 'sinatra/synchrony'
require './models/app_model'
require './models/user'
require './lib/ip_filter'
require './lib/query_args'

class AppController < Sinatra::Base
  register Sinatra::Synchrony
  register Sinatra::OpenApiQueryArgs
  helpers Sinatra::OpenApiIpFilter

  set :controllers, %w[users]
  set :environment, :development

  configure :development do
    set :authentication, false
    set :filter_ip, false
    enable :logging
  end

  configure :production do
    enable :authentication
    set :filter_ip, true
  end

  ActiveRecord::Base.establish_connection YAML::load(File.open('config/database.yml'))[ENV['RACK_ENV']] 

  if settings.authentication?
    use Rack::Auth::Basic, "Restricted Area" do |username, password|
      user = User.find_by_name(username)
      if user
        set :current_user, user
        user.password == password
      else
        false
      end #if
    end 
  end #if

  helpers do
    def model
      Module.const_get(settings.model) rescue 'no model set with controller'
    end

    def json_params
      JSON.parse(request.env["rack.input"].read)
    end

    def json_status(code, reason)
      status code
      {
        :status => code,
        :reason => reason
      }.to_json
    end

    def contain_all_required_fields?(field_type, from_json = false)
      return true if (fields = model.send(field_type)).empty?
      input_params = from_json ? json_params : params.dup
      fields.all? { |field| input_params.has_key?(field) and !input_params[field].empty? }
    end

  end

  before '/' do
    content_type :json

    if settings.filter_ip? and settings.current_user
      halt(403, 'your ip is not allowed'.to_json) unless filter_ip(settings.current_user.allowed_ip)
    end

  end

  get '/' do
    halt(404, 'some fields required'.to_json) unless contain_all_required_fields?(:get_required_fields)
    model.select(model.return_fields).where(params).limit(@limit).offset(@offset).order(@order).to_json
  end

  post '/' do
    halt(404, 'some fields required'.to_json) unless contain_all_required_fields?(:create_required_fields, true)
    json = json_params
    if result = model.send(:create, json)
      result.to_json
    else 
      json_status(404, 'failed to create')
    end #if
  end

  put '/' do
    halt(404, 'some fields required'.to_json) unless contain_all_required_fields?(:update_required_fields, true)
    json = json_params
    id = json.delete("id")
    json_status(404, 'id is required') unless id
    record = model.send(:find, id) rescue nil
    result = nil
    result = record.update_attributes(json) if record
    if result
      json_status(200, 'successfully update')
    else
      json_status(404, 'faild to update')
    end #if
  end

  delete '/' do
    json = json_params
    id = json.delete("id")
    json_status(404, 'id is required') unless id
    record = model.send(:find, id) rescue nil
    puts id
    puts record
    result = nil
    result = record.destroy if record
    if result
      json_status(200, 'successfully delete')
    else
      json_status(404, 'faild to delete')
    end #if
  end 

end

