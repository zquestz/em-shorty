$LOAD_PATH << File.dirname(__FILE__)

# If you want to use sqlite for testing, just comment out the line below
ENV['DATABASE_URL']="mysql2://root:root@localhost:3306/em_shorty"

require 'app'
run App
