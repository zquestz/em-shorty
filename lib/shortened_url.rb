# frozen_string_literal: true

# Class to store necessary info for shortening.
# Just a url to shorten, and an id. so simple.
class ShortenedUrl < ActiveRecord::Base
  attr_accessor :valid_url

  validates_presence_of :url
  validates_uniqueness_of :url
  validates_presence_of :valid_url

  before_validation :validate_url

  # Make sure we have a sane url
  def validate_url
    uri = self.class.parse_url(url)
    return unless uri&.normalized_scheme && uri&.normalized_host
    return unless uri.normalized_host.match(/\.[a-zA-Z][a-zA-Z]/)

    self.url = uri.to_s
    self.valid_url = true
  end

  # Shortens an ID by using alphadecimal format (base62)
  def shorten
    id.alphadecimal
  end

  # Total access count of all api requests and redirects
  def total_count
    redirect_count + json_count + xml_count + yaml_count
  end
  alias count total_count

  # Hash supplied for api hits
  def to_api(base_url = nil)
    { url: url,
      short_url: "#{base_url}/#{shorten}",
      json_count: json_count,
      xml_count: xml_count,
      yaml_count: yaml_count,
      redirect_count: redirect_count,
      total_count: total_count }
  end

  # Find url by its alphadecimal value
  def self.find_by_shortened(shortened)
    find(shortened.alphadecimal)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.find_by_url(url)
    where(url: normalize_url(url)).first
  end

  def self.find_or_create_by_url(url)
    find_by_url(url) || create(url: url)
  end

  # Real url for our system. Everything is filtered.
  def self.normalize_url(url)
    parse_url(url).to_s
  end

  # Use addressable to parse the url
  def self.parse_url(url)
    Addressable::URI.heuristic_parse(url).normalize
  rescue StandardError
    nil
  end
end
