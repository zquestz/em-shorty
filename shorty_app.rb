# em-shorty 0.3.0
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
require 'resolv'
require 'mime/types'
require 'dalli'

# Conditional require's based on environment.
require 'em-resolv-replace' unless settings.environment == :test

# Main application class.
class ShortyApp < Sinatra::Base
  use Rack::FiberPool, :size => 100 unless settings.environment == :test

  set :root, File.dirname(__FILE__)
  set :locales, File.join(File.dirname(__FILE__), 'config', 'en.yml')

  register Sinatra::I18n
  
  API_FORMATS = [:json, :xml, :yaml]
  
  configure do
    ActiveRecord::Base.establish_connection(YAML.load_file(File.join('config', 'database.yml'))[settings.environment.to_s])
    ActiveRecord::Base.logger.level = Logger::INFO
  end

  get '/' do
    haml :index
  end
  
  get '/main.css' do
    content_type 'text/css', :charset => 'utf-8'
    less :main
  end
    
  post '/' do
    cache.fetch "post_#{request.ip}_#{params[:url]}_#{params[:format]}", 60 do
      @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
      format = params[:format]
      if @short_url.valid?
        unless format.blank?
          if API_FORMATS.include?(format.to_sym)
            @short_url.increment!("#{format}_count")
            content_type MIME::Types.of("format.#{format}").first.content_type, :charset => 'utf-8'
            return eval("api_object(@short_url).to_#{format}")
          end
        end
        @flash = {:notice => I18n.translate(:url_shortened, :original_url => params[:url])}
        @viewed_url = "#{current_url}/#{@short_url.shorten}"
        haml :success
      else
        @flash = {:error => t('enter_valid_url')}
        unless format.blank?
          if API_FORMATS.include?(format.to_sym)
            content_type MIME::Types.of("format.#{format}").first.content_type, :charset => 'utf-8'
            return eval("{:error => @flash[:error]}.to_#{format}")
          end
        end
        haml :index
      end
    end
  end
  
  get '/:shortened.:format' do
    cache.fetch "view_#{request.ip}_#{params[:shorten]}_#{params[:format]}", 60 do
      format = params[:format]
      if API_FORMATS.include?(format.to_sym)
        short_url = ShortenedUrl.find_by_shortened(params[:shortened])
        if short_url
          short_url.increment!("#{format}_count")
          shorty = api_object(short_url)
        else
          shorty = {:error => t('no_record_found')}
        end
        content_type MIME::Types.of("format.#{format}").last.content_type, :charset => 'utf-8'
        return eval("shorty.to_#{format}")
      end
    end
  end
  
  get '/:shortened' do
    cache.fetch "redirect_#{request.ip}_#{params[:shortened]}", 60 do
      return if params[:shortened].index('.')
      short_url = ShortenedUrl.find_by_shortened(params[:shortened])
      if short_url
        short_url.increment!("redirect_count")
        redirect short_url.url
      else
        @flash = {:error => t('no_url')}
        haml :index
      end
    end
  end
  
  not_found do
    @flash = {:error => t('http_not_found')}
    haml :index
  end

  error do
    @flash = {:error => t('http_error')}
    haml :index
  end
  
  helpers do
    def cache
      @cache ||= Dalli::Client.new('localhost:11211', {:namespace => 'shorty_'})
    end
    
    def current_url
      @current_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
    
    def api_object(short_url)
      {:url => short_url.url, :short_url => "#{current_url}/#{short_url.shorten}"}
    end
  end

end