# em_shorty 0.1.0
# By: Josh Ellithorpe April 2011
# URL shortner that uses rack fiber pool for optimal performance.
# thin -R config.ru start
# http://localhost:3000/

# Raise an error if we don't have a compatible ruby version.
raise LoadError, "Ruby 1.9.2 required" if RUBY_VERSION < '1.9.2'

# Require needed libs
require 'fiber'
require 'rack/fiber_pool'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/i18n'
require 'alphadecimal'
require 'less'

# Define class for ShortenedUrl
class ShortenedUrl < ActiveRecord::Base
  validates_uniqueness_of :url
  validates_presence_of :url
  validates_format_of :url, :with => /^\b((?:https?:\/\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?]))$/
  
  # Shortens an ID by using alphadecimal format (base62)
  def shorten
    self.id.alphadecimal
  end
  
  # Find url by its alphadecimal value
  def self.find_by_shortened(shortened)
    find(shortened.alphadecimal)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end

# Main application class.
class App < Sinatra::Base
  use Rack::FiberPool
  @fiber_pool = ::FiberPool.new

  set :root, File.dirname(__FILE__)
  set :locales, File.join(File.dirname(__FILE__), 'config/en.yml')

  register Sinatra::I18n

  get '/' do
    haml :index
  end
  
  get '/main.css' do
    less :main
  end
    
  post '/' do
    @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
    if @short_url.valid?
      @flash = {}
      @flash[:notice] = I18n.translate(:url_shortened, :original_url => params[:url]) 
      haml :success
    else
      @flash = {}
      @flash[:error] = t('enter_valid_url')
      haml :index
    end
  end
  
  get '/:shortened' do
    short_url = ShortenedUrl.find_by_shortened(params[:shortened])
    if short_url
      redirect short_url.url
    else
      @flash = {}
      @flash[:error] = t('no_url')
      haml :index
    end
  end

end