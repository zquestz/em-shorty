# Class to store necessary info for shortening. Just a url to shorten, and an id. so simple.
class ShortenedUrl < ActiveRecord::Base
  validates_uniqueness_of :url
  validates_presence_of :url
  validates_format_of :url, :with => /^\b((?:https?:\/\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?]))$/
  
  # Shortens an ID by using alphadecimal format (base62)
  def shorten
    self.id.alphadecimal
  end
  
  # Find url by its alphadecimal value
  def self.find_by_shortened(shortened)
    find(shortened.alphadecimal)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end