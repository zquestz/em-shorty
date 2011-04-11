# Add the root to the load path.
$LOAD_PATH << File.dirname(__FILE__)

# Require items we need for rake tasks
require 'sinatra/activerecord/rake'
require 'rake/testtask'

# Setup test rake task, and make it default
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :console do
  ENV['RACK_ENV'] = 'test'
  exec "tux"
end

task :default => :test