# frozen_string_literal: true

# Add the root to the load path.
$LOAD_PATH << File.dirname(__FILE__)

# Startup the app
require 'shorty_app'
run ShortyApp
