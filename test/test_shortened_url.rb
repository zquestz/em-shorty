# frozen_string_literal: true

require 'helper'

class TestShortenedUrl < Minitest::Test
  def test_empty_shortened_url
    short_url = ShortenedUrl.new
    assert_equal false, short_url.save
  end

  def test_invalid_shortened_url
    matchers = ['localhost', 'http://bad.a', 'http://localhost']
    matchers.each do |matcher|
      short_url = ShortenedUrl.new(url: matcher)
      assert_equal false, short_url.save
    end
  end

  def test_valid_shortened_url
    matchers = ['reddit.com/r/ruby', 'https://facebook.com', 'http:/intrarts.com', 'http://bit.ly', 'ftp://host.com']
    matchers.each do |matcher|
      short_url = ShortenedUrl.new(url: matcher)
      assert_equal true, short_url.save
      short_url.delete
    end
  end

  def test_normalize_url
    url = 'http:/needs.normalizing.com'
    assert url != ShortenedUrl.normalize_url(url)
  end

  def test_normalize_on_save
    url = 'http:intrarts.com'
    short_url = ShortenedUrl.create(url: url)
    assert url != short_url.url
    assert_equal ShortenedUrl.normalize_url(url), short_url.url
    short_url.delete
  end

  def test_parse_url
    url = 'http://intrarts.com'
    assert_equal ShortenedUrl.parse_url(url).class, Addressable::URI
  end

  def test_shorten
    short_url = ShortenedUrl.create(url: 'http://thelag.dyndns.org')
    assert_equal short_url.shorten, short_url.id.alphadecimal
    assert_equal 1.alphadecimal, '1'
    assert_equal 10.alphadecimal, 'A'
    short_url.delete
  end

  def test_find_by_shorten
    short_url = ShortenedUrl.create(url: 'http://phandroid.com')
    assert_equal ShortenedUrl.find_by_shortened(short_url.shorten), short_url
    short_url.delete
  end

  def test_find_by_url
    short_url = ShortenedUrl.create(url: 'http://phandroid.com')
    assert_equal ShortenedUrl.find_by_url(short_url.url), short_url
    short_url.delete
  end

  def test_find_or_create_by_url
    short_url = ShortenedUrl.find_or_create_by_url('http://newegg.com')
    assert_equal ShortenedUrl.find_by_url(short_url.url), short_url
    short_url.delete
  end
end
