# em-shorty 0.5.0
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
require 'mysql2/em'
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

# Make home page respond to both get and post.
def home(url, verbs = %w(get post), &block)
  verbs.each do |verb|
    send(verb, url, &block)
  end
end

# Main application class.
class ShortyApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :locales, File.join(File.dirname(__FILE__), 'config', 'en.yml')
  set :api_formats, [:json, :xml, :yaml]
  set :memcached, '127.0.0.1:11211'
  set :sockets, ['/opt/local/var/run/mysql5/mysqld.sock', 
                  '/var/run/mysqld/mysqld.sock', 
                  '/tmp/mysql.sock']
  set :caching, true
  set :cache_timeout, 120
  set :cache, settings.caching ? Dalli::Client.new(settings.memcached, {:namespace => 'shorty_', :expires_in => settings.cache_timeout}) : CacheProxy.new()
  
  use Rack::FiberPool, :size => 100 unless test?

  register Sinatra::I18n
  
  configure do
    db_config = YAML.load_file(File.join('config', 'database.yml'))[settings.environment.to_s]
    db_config.merge!({'socket' => settings.sockets.find { |f| File.exist? f } }) if db_config['socket']
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.logger.level = Logger::INFO
  end
  
  before do
    set_content_type(params[:format])
  end
    
  home '/' do
    if params[:url]
      settings.cache.fetch "shorten_#{request.ip}_#{params[:url]}_#{params[:format]}".hashify do
        @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
        format = params[:format]
        if @short_url.valid?
          if format.blank?
            @flash = {:notice => I18n.translate(:url_shortened, :original_url => @short_url.url)}
            @viewed_url = "#{current_url}/#{@short_url.shorten}"
            haml :success
          else
            if settings.api_formats.include?(format.to_sym)
              @short_url.increment!("#{format}_count")
              erb :api_output, :layout => false, :locals => {:api_output => api_object(@short_url).send("to_#{format}")}
            end
          end
        else
          @flash = {:error => t('enter_valid_url')}
          if format.blank?
            haml :index
          else
            if settings.api_formats.include?(format.to_sym)
              erb :api_output, :layout => false, :locals => {:api_output => {:error => @flash[:error]}.send("to_#{format}")}
            end
          end
        end
      end
    else
      cache_control :public, :must_revalidate, :max_age => (settings.cache_timeout * 10)
      haml :index
    end
  end
  
  get '/main.css' do
    cache_control :public, :must_revalidate, :max_age => (settings.cache_timeout * 10)
    content_type 'text/css', :charset => 'utf-8'
    less :main
  end
  
  get '/:shortened.:format' do
    set_content_type(params[:format])
    settings.cache.fetch "view_#{request.ip}_#{params[:shortened]}_#{params[:format]}".hashify do
      format = params[:format]
      if settings.api_formats.include?(format.to_sym)
        short_url = ShortenedUrl.find_by_shortened(params[:shortened])
        if short_url
          short_url.increment!("#{format}_count")
          shorty = api_object(short_url)
        else
          shorty = {:error => t('no_record_found')}
        end
        erb :api_output, :layout => false, :locals => {:api_output => shorty.send("to_#{format}")}
      end
    end
  end
  
  get '/:shortened' do
    settings.cache.fetch "redirect_#{request.ip}_#{params[:shortened]}".hashify do
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
    def set_content_type(format)
      if format && settings.api_formats.include?(format.to_sym)
        content_type MIME::Types.of("format.#{format}").first.content_type, :charset => 'utf-8'
      end
    end
    
    def flush_cache
      settings.cache.flush
    end
    
    def current_url
      @current_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
    
    def api_object(short_url)
      short_url.to_api(current_url)
    end
  end

end
