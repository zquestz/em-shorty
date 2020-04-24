# frozen_string_literal: true

require 'helper'

class TestShortyApp < Minitest::Test
  include Rack::Test::Methods

  def app
    ShortyApp
  end

  def current_url
    "#{last_request.env['rack.url_scheme']}://#{last_request.env['HTTP_HOST']}"
  end

  def test_front_page_essentials
    get '/'
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), I18n.translate('shorten_button'), 'url.value.length > 0 ? true : false', 'main.css', 'favicon.png', 'logo.png', 'input', 'submit', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end

  def test_main_css
    get '/main.css'
    assert last_response.ok?
    assert last_response.body.include?('background')
  end

  def test_focus
    get '/'
    assert last_response.ok?
    matchers = ["document.getElementById('url')", 'url.focus();']
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end

  def test_post_valid_new_url
    url = 'http://gizmodo.com'
    post '/', url: url
    assert last_response.ok?
    short_url = ShortenedUrl.find_by_url(url)
    assert !short_url.nil?
    assert_equal short_url.count, 0
    matchers = ["/#{short_url.shorten}", I18n.translate('app_name'), I18n.translate('source_url'), current_url, I18n.translate('url_shortened', original_url: short_url.url), 'main.css', 'favicon.png', 'logo.png', 'urljumper', 'keyPressed', 'notice', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
    short_url.delete
  end

  def test_get_valid_new_url
    url = 'http://arstechnica.com'
    get '/', url: url
    assert last_response.ok?
    short_url = ShortenedUrl.find_by_url(url)
    assert !short_url.nil?
    assert_equal short_url.count, 0
    matchers = ["/#{short_url.shorten}", I18n.translate('app_name'), I18n.translate('source_url'), current_url, I18n.translate('url_shortened', original_url: short_url.url), 'main.css', 'favicon.png', 'logo.png', 'urljumper', 'keyPressed', 'notice', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
    short_url.delete
  end

  def test_post_addressable_heuristic_parse_url
    urls = ['http://macnn.com', 'http:/macnn.com']
    urls.each do |url|
      post '/', url: url
      assert last_response.ok?
    end
    assert_equal ShortenedUrl.all.length, 1
    ShortenedUrl.find_by_url(urls.first).delete
  end

  def test_get_addressable_heuristic_parse_url
    urls = ['http://padk-rad.com', 'http:/padk-rad.com']
    urls.each do |url|
      get '/', url: url
      assert last_response.ok?
    end
    assert_equal ShortenedUrl.all.length, 1
    ShortenedUrl.find_by_url(urls.first).delete
  end

  def test_post_valid_new_url_json
    url = 'http://involver.com'
    post '/', { url: url, format: 'json' }
    assert last_response.ok?
    short_url = ShortenedUrl.find_by_url(url)
    assert !short_url.nil?
    assert_equal short_url.count, 1
    assert_equal short_url.json_count, 1
    assert_equal short_url.to_api(current_url).to_json, last_response.body
    short_url.delete
  end

  def test_get_valid_new_url_json
    url = 'http://youtube.com'
    get '/', { url: url, format: 'json' }
    assert last_response.ok?
    short_url = ShortenedUrl.find_by_url(url)
    assert !short_url.nil?
    assert_equal short_url.count, 1
    assert_equal short_url.json_count, 1
    assert_equal short_url.to_api(current_url).to_json, last_response.body
    short_url.delete
  end

  def test_post_valid_new_url_xml
    url = 'http://bash.org'
    post '/', { url: url, format: 'xml' }
    assert last_response.ok?
    short_url = ShortenedUrl.find_by_url(url)
    assert !short_url.nil?
    assert_equal short_url.count, 1
    assert_equal short_url.xml_count, 1
    assert_equal short_url.to_api(current_url).to_xml, last_response.body
    short_url.delete
  end

  def test_get_valid_new_url_xml
    url = 'http://insecure.org'
    get '/', { url: url, format: 'xml' }
    assert last_response.ok?
    short_url = ShortenedUrl.find_by_url(url)
    assert !short_url.nil?
    assert_equal short_url.count, 1
    assert_equal short_url.xml_count, 1
    assert_equal short_url.to_api(current_url).to_xml, last_response.body
    short_url.delete
  end

  def test_post_valid_new_url_yaml
    url = 'http://thedailyshow.com'
    post '/', { url: url, format: 'yaml' }
    assert last_response.ok?
    short_url = ShortenedUrl.find_by_url(url)
    assert !short_url.nil?
    assert_equal short_url.count, 1
    assert_equal short_url.yaml_count, 1
    assert_equal short_url.to_api(current_url).to_yaml, last_response.body
    short_url.delete
  end

  def test_get_valid_new_url_yaml
    url = 'http://metacafe.com'
    get '/', { url: url, format: 'yaml' }
    assert last_response.ok?
    short_url = ShortenedUrl.find_by_url(url)
    assert !short_url.nil?
    assert_equal short_url.count, 1
    assert_equal short_url.yaml_count, 1
    assert_equal short_url.to_api(current_url).to_yaml, last_response.body
    short_url.delete
  end

  def test_post_clipboard
    url = 'http://involver.com'
    post '/', url: url
    assert last_response.ok?
    matchers = ['clipboard.min.js', 'new ClipboardJS(\'#clip_button\');', 'data-clipboard-text']
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
    ShortenedUrl.find_by_url(url).delete
  end

  def test_get_clipboard
    url = 'http://servercentral.net'
    get '/', url: url
    assert last_response.ok?
    matchers = ['clipboard.min.js', 'new ClipboardJS(\'#clip_button\');', 'data-clipboard-text']
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
    ShortenedUrl.find_by_url(url).delete
  end

  def test_post_invalid_new_url
    post '/', url: 'blah'
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), I18n.translate('enter_valid_url'), 'main.css', 'favicon.png', 'logo.png', 'error', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end

  def test_get_invalid_new_url
    get '/', url: 'blah'
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), I18n.translate('enter_valid_url'), 'main.css', 'favicon.png', 'logo.png', 'error', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end

  def test_post_invalid_new_url_json
    post '/', { url: 'blah', format: 'json' }
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('enter_valid_url') }.to_json), last_response.body
  end

  def test_get_invalid_new_url_json
    get '/', { url: 'blah', format: 'json' }
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('enter_valid_url') }.to_json), last_response.body
  end

  def test_post_invalid_new_url_xml
    post '/', { url: 'blah', format: 'xml' }
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('enter_valid_url') }.to_xml), last_response.body
  end

  def test_get_invalid_new_url_xml
    get '/', { url: 'blah', format: 'xml' }
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('enter_valid_url') }.to_xml), last_response.body
  end

  def test_post_invalid_new_url_yaml
    post '/', { url: 'blah', format: 'yaml' }
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('enter_valid_url') }.to_yaml), last_response.body
  end

  def test_get_invalid_new_url_yaml
    get '/', { url: 'blah', format: 'yaml' }
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('enter_valid_url') }.to_yaml), last_response.body
  end

  def test_url_redirect
    short_url = ShortenedUrl.create(url: 'http://google.com/')
    old_count = short_url.count
    get "/#{short_url.shorten}"
    follow_redirect!
    assert last_response.ok?
    assert_equal short_url.reload.count, (old_count + 1)
    assert_equal short_url.redirect_count, (old_count + 1)
    assert_equal short_url.url, last_request.url
    short_url.delete
  end

  def test_invalid_url_redirect
    get '/____'
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), I18n.translate('no_url'), 'main.css', 'favicon.png', 'logo.png', 'input', 'submit', 'error', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end

  def test_xml
    short_url = ShortenedUrl.create(url: 'http://reddit.com/r/xml')
    old_count = short_url.count
    get "/#{short_url.shorten}.xml"
    assert last_response.ok?
    assert_equal short_url.reload.count, (old_count + 1)
    assert_equal short_url.reload.xml_count, (old_count + 1)
    assert_equal short_url.to_api(current_url).to_xml, last_response.body
    short_url.delete
  end

  def test_json
    short_url = ShortenedUrl.create(url: 'http://reddit.com/r/json')
    old_count = short_url.count
    get "/#{short_url.shorten}.json"
    assert last_response.ok?
    assert_equal short_url.reload.count, (old_count + 1)
    assert_equal short_url.reload.json_count, (old_count + 1)
    assert_equal short_url.to_api(current_url).to_json, last_response.body
    short_url.delete
  end

  def test_yaml
    short_url = ShortenedUrl.create(url: 'http://reddit.com/r/yaml')
    old_count = short_url.count
    get "/#{short_url.shorten}.yaml"
    assert last_response.ok?
    assert_equal short_url.reload.count, (old_count + 1)
    assert_equal short_url.reload.yaml_count, (old_count + 1)
    assert_equal short_url.to_api(current_url).to_yaml, last_response.body
    short_url.delete
  end

  def test_bad_xml
    get '/___.xml'
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('no_record_found') }.to_xml), last_response.body
  end

  def test_bad_json
    get '/___.json'
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('no_record_found') }.to_json), last_response.body
  end

  def test_bad_yaml
    get '/___.yaml'
    assert last_response.ok?
    assert_equal ({ error: I18n.translate('no_record_found') }.to_yaml), last_response.body
  end

  def test_404
    get '/fake/path'
    assert_equal 404, last_response.status
    assert last_response.body.include?(I18n.translate('http_not_found'))
  end

  def test_memcached
    assert_equal app.settings.cache.class, Dalli::Client if app.settings.caching == true
  end

  def test_passthru
    assert_equal app.settings.cache.class, CacheProxy if app.settings.caching == false
  end
end
