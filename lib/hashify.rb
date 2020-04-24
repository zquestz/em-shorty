# frozen_string_literal: true

# Add popular hashing functions to strings.
# Then wrap in a nice hashify method.
module Hashify
  VALID_FORMATS = %i[md5 sha1 sha2].freeze

  def self.included(included_class)
    included_class.class_eval do
      def self.default_hash
        @default_hash ||= :sha1
      end

      def self.default_hash=(format)
        @default_hash = format if VALID_FORMATS.include?(format)
      end

      def hashify(format = self.class.default_hash)
        send("to_#{format}") if VALID_FORMATS.include?(format)
      end

      def to_md5
        Digest::MD5.hexdigest(to_s)
      end

      def to_sha1
        Digest::SHA1.hexdigest(to_s)
      end

      def to_sha2
        Digest::SHA2.hexdigest(to_s)
      end
    end
  end
end

# Monkeypatch String to include Hashify
class String
  include Hashify
end

# Monkeypatch Array to include Hashify
class Array
  include Hashify
end

# Monkeypatch Hash to include Hashify
class Hash
  include Hashify
end
