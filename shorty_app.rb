# em_shorty 0.1.0
# By: Josh Ellithorpe April 2011
# URL shortner that uses rack fiber pool for optimal performance.
# thin -R config.ru start
# http://localhost:3000/

# Raise an error if we don't have a compatible ruby version.
raise LoadError, "Ruby 1.9.2 required" if RUBY_VERSION < '1.9.2'

# Add lib directory to load path
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

# Require needed libs
require 'fiber'
require 'rack/fiber_pool'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/i18n'
require 'alphadecimal'
require 'less'
require 'shortened_url'

# Main application class.
class ShortyApp < Sinatra::Base
  use Rack::FiberPool unless ENV['RACK_ENV'] == 'test'

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
      @viewed_url = "#{t('app_host')}/#{@short_url.shorten}"
      haml :success
    else
      @flash = {}
      @flash[:error] = t('enter_valid_url')
      haml :index
    end
  end
  
  get '/:shortened.:format' do
    short_url = ShortenedUrl.find_by_shortened(params[:shortened])
    if short_url
      shorty = {:url => short_url.url, :short_url => "#{t('app_host')}/#{short_url.id.alphadecimal}"}
    else
      shorty = {:error => t('no_record_found')}
    end
    case params[:format]
      when 'json' then shorty.to_json 
      when 'xml' then shorty.to_xml
      when 'yaml' then shorty.to_yaml 
    end
  end
  
  get '/:shortened' do
    return if params[:shortened].index('.')
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