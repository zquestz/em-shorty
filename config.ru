# Add the root to the load path.
$LOAD_PATH << File.dirname(__FILE__)

# Launch in production mode.
ENV['RACK_ENV']='production'

# Startup the app
require 'shorty_app'
run ShortyApp
