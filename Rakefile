# frozen_string_literal: true

# Fixes em-mysql2 error when running rake.
require 'bundler'
Bundler.setup

# Add the root to the load path.
$LOAD_PATH << File.dirname(__FILE__)

# Require items we need for rake tasks
require 'sinatra/activerecord/rake'
require 'rake/testtask'

# Silence warnings
ENV['RUBYOPT'] = "-W0 #{ENV['RUBYOPT']}"

# Setup test rake task, and make it default
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :console do
  ENV['RACK_ENV'] ||= 'test'
  exec 'tux'
end

namespace :db do
  task :load_config do
    require 'shorty_app'
  end
end

namespace :docker do
  desc 'build docker image'
  task :build do
    # TODO: Stream output
    puts 'Building em-shorty docker image'
    puts `docker build -f Dockerfile -t em-shorty .`
  end
end

task default: :test
