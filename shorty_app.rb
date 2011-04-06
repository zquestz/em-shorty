# em_shorty 0.1.0
# By: Josh Ellithorpe April 2011
# URL shortner that uses rack fiber pool for optimal performance.
# thin -R config.ru start
# http://localhost:3000/

# Raise an error if we don't have a compatible ruby version.
raise LoadError, "Ruby 1.9.2 required" if RUBY_VERSION < '1.9.2'

if ENV['RACK_ENV'] == 'production'
  ENV['DATABASE_URL'] = "mysql2://root:root@localhost:3306/em_shorty"
end

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
  use Rack::FiberPool, :size => 100 unless ENV['RACK_ENV'] == 'test'

  set :root, File.dirname(__FILE__)
  set :locales, File.join(File.dirname(__FILE__), 'config', 'en.yml')

  register Sinatra::I18n

  get '/' do
    haml :index
  end
  
  get '/main.css' do
    less :main
  end
    
  post '/' do
    @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
    formats = [:json, :xml, :yaml]
    format = params[:format]
    if @short_url.valid?
      unless format.blank?
        (redirect "/#{@short_url.shorten}.#{format}") if formats.include?(format.to_sym)
      end
      @flash = {}
      @flash[:notice] = I18n.translate(:url_shortened, :original_url => params[:url])
      @viewed_url = "#{t('app_host')}/#{@short_url.shorten}"
      haml :success
    else
      @flash = {}
      @flash[:error] = t('enter_valid_url')
      unless format.blank?
        return eval("{:error => @flash[:error]}.to_#{format}") if formats.include?(format.to_sym)
      end
      haml :index
    end
  end
  
  get '/:shortened.:format' do
    formats = [:json, :xml, :yaml]
    format = params[:format]
    if formats.include?(format.to_sym)
      short_url = ShortenedUrl.find_by_shortened(params[:shortened])
      if short_url
        short_url.increment!("#{format}_count")
        shorty = {:url => short_url.url, :short_url => "#{t('app_host')}/#{short_url.shorten}"}
      else
        shorty = {:error => t('no_record_found')}
      end
      return eval("shorty.to_#{format}")
    end
  end
  
  get '/:shortened' do
    return if params[:shortened].index('.')
    short_url = ShortenedUrl.find_by_shortened(params[:shortened])
    if short_url
      short_url.increment!("redirect_count")
      redirect short_url.url
    else
      @flash = {}
      @flash[:error] = t('no_url')
      haml :index
    end
  end
  
  not_found do
    @flash = {}
    @flash[:error] = t('http_not_found')
    haml :index
  end

  error do
    @flash = {}
    @flash[:error] = t('http_error')
    haml :index
  end

end