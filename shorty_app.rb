# em-shorty 0.3.0
# By: Josh Ellithorpe April 2011
# URL shortner that uses rack fiber pool for optimal performance.
# thin -R config.ru start
# http://localhost:3000/

# Raise an error if we don't have a compatible ruby version.
raise LoadError, 'Ruby 1.9.2 required' if RUBY_VERSION < '1.9.2'

# Add lib directory to load path
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

# Require needed libs
require 'fiber'
require 'rack/fiber_pool'
require 'rack/cache'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/i18n'
require 'alphadecimal'
require 'less'
require 'shortened_url'
require 'cache_proxy'
require 'resolv'
require 'mime/types'
require 'dalli'
require 'hashify'
require 'em-synchrony/em-http'

# Conditional require's based on environment.
require 'em-resolv-replace' unless test?

# Main application class.
class ShortyApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :locales, File.join(File.dirname(__FILE__), 'config', 'en.yml')
  set :api_formats, [:json, :xml, :yaml]
  set :memcached, 'localhost:11211'
  set :sockets, ['/opt/local/var/run/mysql5/mysqld.sock', 
                  '/var/run/mysqld/mysqld.sock', 
                  '/tmp/mysql.sock']
  enable :caching
  enable :rack_cache
  
  use Rack::FiberPool, :size => 100 unless test?
  
  if settings.rack_cache
    use Rack::Cache,
      :verbose => false,
      :metastore => "memcached://#{settings.memcached}/meta",
      :entitystore => "file:cache"
  end

  register Sinatra::I18n
  
  configure do
    db_config = YAML.load_file(File.join('config', 'database.yml'))[settings.environment.to_s]
    db_config.merge!({'socket' => settings.sockets.find { |f| File.exist? f } }) if db_config['socket']
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.logger.level = Logger::INFO
  end
  
  get '/' do
    cache_control :public, :must_revalidate, :max_age => 3600
    haml :index
  end
  
  get '/main.css' do
    cache_control :public, :must_revalidate, :max_age => 3600
    content_type 'text/css', :charset => 'utf-8'
    less :main
  end
    
  post '/' do
    cache.fetch "post_#{request.ip}_#{params[:url]}_#{params[:format]}".hashify, 60 do
      @short_url = ShortenedUrl.find_or_create_by_url(ShortenedUrl.parse_url(params[:url]).to_s)
      format = params[:format]
      if @short_url.valid?
        unless format.blank?
          if settings.api_formats.include?(format.to_sym)
            @short_url.increment!("#{format}_count")
            content_type MIME::Types.of("format.#{format}").first.content_type, :charset => 'utf-8'
            return api_object(@short_url).send("to_#{format}")
          end
        end
        @flash = {:notice => I18n.translate(:url_shortened, :original_url => @short_url.url)}
        @viewed_url = "#{current_url}/#{@short_url.shorten}"
        haml :success
      else
        @flash = {:error => t('enter_valid_url')}
        unless format.blank?
          if settings.api_formats.include?(format.to_sym)
            content_type MIME::Types.of("format.#{format}").first.content_type, :charset => 'utf-8'
            return {:error => @flash[:error]}.send("to_#{format}")
          end
        end
        haml :index
      end
    end
  end
  
  get '/:shortened.:format' do
    cache_control :public, :must_revalidate, :max_age => 60
    cache.fetch "view_#{request.ip}_#{params[:shorten]}_#{params[:format]}".hashify, 60 do
      format = params[:format]
      if settings.api_formats.include?(format.to_sym)
        short_url = ShortenedUrl.find_by_shortened(params[:shortened])
        if short_url
          short_url.increment!("#{format}_count")
          shorty = api_object(short_url)
        else
          shorty = {:error => t('no_record_found')}
        end
        content_type MIME::Types.of("format.#{format}").last.content_type, :charset => 'utf-8'
        return shorty.send("to_#{format}")
      end
    end
  end
  
  get '/:shortened' do
    cache_control :public, :must_revalidate, :max_age => 60
    cache.fetch "redirect_#{request.ip}_#{params[:shortened]}".hashify, 60 do
      return if params[:shortened].index('.')
      short_url = ShortenedUrl.find_by_shortened(params[:shortened])
      if short_url
        short_url.increment!('redirect_count')
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
      @cache ||= if settings.caching
        Dalli::Client.new(settings.memcached, {:namespace => 'shorty_'})
      else
        CacheProxy.new()
      end
    end
    
    def flush_cache
      cache.flush
    end
    
    def current_url
      @current_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
    
    def api_object(short_url)
      {:url => short_url.url, :short_url => "#{current_url}/#{short_url.shorten}"}
    end
  end

end