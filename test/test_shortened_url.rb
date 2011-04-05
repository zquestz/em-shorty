require 'helper'

class TestShortenedUrl < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ShortyApp
  end
  
  def test_empty_shortened_url
    short_url = ShortenedUrl.new
    assert_equal false, short_url.save
  end
  
  def test_invalid_shortened_url
    short_url = ShortenedUrl.new(:url => "bad")
    assert_equal false, short_url.save
  end
  
  def test_valid_shortened_url
    short_url = ShortenedUrl.new(:url => "http://intrarts.com")
    assert_equal true, short_url.save
    short_url.delete
  end
  
  def test_shorten
    assert_equal 1.alphadecimal, '1'
    assert_equal 10.alphadecimal, 'A'
  end
  
  def test_find_by_shorten
    short_url = ShortenedUrl.create(:url => "http://intrarts.com")
    assert_equal ShortenedUrl.find_by_shortened(short_url.id.alphadecimal), short_url
    short_url.delete
  end
end