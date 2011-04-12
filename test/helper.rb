# Add the root to the load path.
$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

# Set RACK_ENV to test
ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

# require items needed for testing
require 'shorty_app'
require 'test/unit'
require 'rack/test'

# Cleanup data sources
ShortenedUrl.all.map(&:delete)
ShortyApp.new.flush_cache