require 'rubygems'
require 'bundler'

Bundler.require

module Config
  def self.production?
    ENV["RACK_ENV"] == "production"
  end

  def self.development?
    !production?
  end
end

if ENV["RACK_ENV"] == "production"
  # don't use Dotenv
else
  require 'dotenv'
  Dotenv.load
end

require "./lib/ovid"
require "./workers/case_data_worker"
require "sidekiq-status"

Sidekiq.configure_client do |config|
  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 60 * 30
end

Sidekiq.configure_server do |config|
  # accepts :expiration (optional)
  Sidekiq::Status.configure_server_middleware config, expiration: 60 * 30

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 60 * 30
end
