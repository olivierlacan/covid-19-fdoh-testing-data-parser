# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby "2.7.1"

gem "rack"
gem "redis"
gem "bugsnag", "~> 6.13"
gem "hanami-router"
gem "puma"
gem "rack-ssl-enforcer"
gem "sidekiq"
gem "ice_nine"
gem "oj"

group :development do
  gem "dotenv"
  gem "rerun"
  gem "terminal-notifier"
  gem "foreman"
  gem "pdf-reader"
  gem "memory_profiler"
end
