# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activerecord', '~> 4.1.10'
gem 'alphadecimal'
gem 'dalli', '~> 2.7.10'
gem 'dotenv'
gem 'em-http-request'
gem 'em-resolv-replace'
gem 'em-synchrony', git: 'https://github.com/igrigorik/em-synchrony'
gem 'haml', '~> 5.2.2'
gem 'mime-types'
gem 'parser', '~> 2.7.1'
gem 'rack-fiber_pool'
gem 'rack-ssl-enforcer'
gem 'rack-test'
gem 'rake'
gem 'sass'
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'sinatra-i18n'
gem 'sqlite3', '~> 1.3.6'
gem 'thin', '~> 1.7.2'
gem 'tux'

group :test do
  gem 'rubocop', '~> 0.81.0'
  gem 'simplecov', '>= 0.4.0', require: false, group: :test
end

group :development, :production do
  gem 'mysql2', '~> 0.3.0'
end
