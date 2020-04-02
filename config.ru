# config.ru
require 'rack/env'
require_relative './config/environment'

if ENV['RACK_ENV']=='production'
  redis_hash = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}", password: "#{ENV['REDIS_PASSWORD']}" }
  use Rack::Env
else
  redis_hash = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}" }
  use Rack::Env, envfile: "#{File.expand_path(File.dirname(File.dirname(__FILE__)))}/.env"
end

Sidekiq.configure_client do |config|
  config.redis = redis_hash
end
require "./app"
run App