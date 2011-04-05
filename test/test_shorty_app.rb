require 'helper'

class TestShortyApp < Test::Unit::TestCase
  include Rack::Test::Methods

  ShortenedUrl.all.map(&:delete)

  def app
    ShortyApp
  end

  def test_front_page_essentials
    get '/'
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), 'main.css', 'favicon.png', 'logo.png', 'input', 'submit', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end
  
  def test_post_valid_new_url
    post '/', :url => "http://involver.com"
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), I18n.translate('app_host'), I18n.translate('url_shortened', :original_url => "http://involver.com"), 'main.css', 'favicon.png', 'logo.png', 'http://involver.com', 'urljumper', 'enterPressed', 'notice', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end
  
  def test_post_invalid_new_url
    post '/', :url => "blah"
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), I18n.translate('enter_valid_url'), 'main.css', 'favicon.png', 'logo.png', 'error', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end
  
  def test_url_redirect
    short_url = ShortenedUrl.create!(:url => "http://google.com/")
    get "/#{short_url.id.alphadecimal}"
    follow_redirect!
    assert last_response.ok?
    assert_equal short_url.url, last_request.url
  end
  
  def test_invalid_url_redirect
    short_url = ShortenedUrl.create!(:url => "http://engadget.com/")
    get "/____"
    assert last_response.ok?
    matchers = [I18n.translate('app_name'), I18n.translate('source_url'), I18n.translate('no_url'), 'main.css', 'favicon.png', 'logo.png', 'input', 'submit', 'error', Time.now.year.to_s]
    matchers.each do |match|
      assert last_response.body.include?(match)
    end
  end
  
  def test_xml
    short_url = ShortenedUrl.create(:url => "http://reddit.com/r/xml")
    get "/#{short_url.id.alphadecimal}.xml"
    assert last_response.ok?
    assert_equal ({:url => short_url.url, :short_url => "#{I18n.translate('app_host')}/#{short_url.id.alphadecimal}"}.to_xml), last_response.body
  end
  
  def test_json
    short_url = ShortenedUrl.create(:url => "http://reddit.com/r/json")
    get "/#{short_url.id.alphadecimal}.json"
    assert last_response.ok?
    assert_equal ({:url => short_url.url, :short_url => "#{I18n.translate('app_host')}/#{short_url.id.alphadecimal}"}.to_json), last_response.body
  end
  
  def test_yaml
    short_url = ShortenedUrl.create(:url => "http://reddit.com/r/yaml")
    get "/#{short_url.id.alphadecimal}.yaml"
    assert last_response.ok?
    assert_equal ({:url => short_url.url, :short_url => "#{I18n.translate('app_host')}/#{short_url.id.alphadecimal}"}.to_yaml), last_response.body
  end
  
  def test_bad_xml
    get "/___.xml"
    assert last_response.ok?
    assert_equal ({:error => I18n.translate('no_record_found')}.to_xml), last_response.body
  end
  
  def test_bad_json
    get "/___.json"
    assert last_response.ok?
    assert_equal ({:error => I18n.translate('no_record_found')}.to_json), last_response.body
  end
  
  def test_bad_yaml
    get "/___.yaml"
    assert last_response.ok?
    assert_equal ({:error => I18n.translate('no_record_found')}.to_yaml), last_response.body
  end
  
end