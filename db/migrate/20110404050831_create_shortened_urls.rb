class CreateShortenedUrls < ActiveRecord::Migration
  def self.up
    create_table :shortened_urls do |t|
      t.string :url
      t.datetime :updated_at
      t.datetime :created_at
    end
    add_index :shortened_urls, :url
  end

  def self.down
    drop_table :shortened_urls
  end
end