# config.ru
require 'rack/env'
require_relative './config/environment'
require "sidekiq"
require 'sidekiq/web'
require "active_support/security_utils"
require "./app"

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

use Rack::Env
Sidekiq::Web.use Rack::Auth::Basic, "Admin" do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD']))
end

run Rack::URLMap.new(
    "/sidekiq" => Sidekiq::Web,
    "/" => App
) 