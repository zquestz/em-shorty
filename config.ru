# Add the root to the load path.
$LOAD_PATH << File.dirname(__FILE__)

# Setup MySQL database
ENV['DATABASE_URL']="mysql2://root:root@localhost:3306/em_shorty"

# Startup the app
require 'shorty_app'
run ShortyApp
