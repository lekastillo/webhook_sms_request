require "active_support/security_utils"
require "./app"
require "sidekiq"
require 'sidekiq/web'

Sidekiq.configure_client do |config|
    config.redis = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}" }
end

use Rack::Env
Sidekiq::Web.use Rack::Auth::Basic, "Admin" do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest("#{ENV['SIDEKIQ_USERNAME']}")) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest("#{ENV['SIDEKIQ_PASSWORD']}"))
end

# config.ru
run Rack::URLMap.new(
    "/sidekiq" => Sidekiq::Web,
    "/" => App
) 