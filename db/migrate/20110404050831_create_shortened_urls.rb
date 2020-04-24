# frozen_string_literal: true

# CreateShortenedUrls creates the shortened_urls table.
class CreateShortenedUrls < ActiveRecord::Migration
  def self.up
    create_table :shortened_urls do |t|
      t.string :url
      t.integer :redirect_count, default: 0
      t.integer :json_count, default: 0
      t.integer :xml_count, default: 0
      t.integer :yaml_count, default: 0
      t.datetime :updated_at
      t.datetime :created_at
    end
    add_index :shortened_urls, :url
  end

  def self.down
    drop_table :shortened_urls
  end
end
