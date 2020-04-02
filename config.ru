# config.ru
require 'rack/env'
require_relative './config/environment'

if ENV['RACK_ENV']=='production'
  use Rack::Env
  redis_hash = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}", password: "#{ENV['REDIS_PASSWORD']}" }
else
  use Rack::Env, envfile: "#{File.expand_path(File.dirname(File.dirname(__FILE__)))}/.env"
  redis_hash = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}" }
end

Sidekiq.configure_client do |config|
  config.redis = redis_hash
end
require "./app"
run App
