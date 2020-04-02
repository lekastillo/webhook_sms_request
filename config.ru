# config.ru
require 'rack/env'
require_relative './config/environment'
use Rack::Env, envfile: '.env'
if ENV['RACK_ENV']=='development'
  redis_hash = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}" }
else
  redis_hash = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}", password: "#{ENV['REDIS_PASSWORD']}" }
end

Sidekiq.configure_client do |config|
  config.redis = redis_hash
end
require "./app"
run App