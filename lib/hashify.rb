# Add popular hashing functions to strings.
# Then wrap in a nice hashify method.

module Hashify
  
  VALID_FORMATS = [:md5, :sha1, :sha2]
  
  def self.included(included_class)
    included_class.class_eval do
      def self.default_hash
        @@default_hash ||= :sha1
      end

      def self.default_hash=(hash_type)
        @@default_hash = hash_type if VALID_FORMATS.include?(format)
      end

      def hashify_string
        "#{self.class}_#{self}"
      end

      def hashify(format = self.class.default_hash)
        self.send("to_#{format}") if VALID_FORMATS.include?(format)
      end

      def to_md5
        Digest::MD5.hexdigest(hashify_string)
      end

      def to_sha1
        Digest::SHA1.hexdigest(hashify_string)
      end

      def to_sha2
        Digest::SHA2.hexdigest(hashify_string)
      end
    end
  end

end

class String
  include Hashify
end

class Array
  include Hashify
end

class Hash
  include Hashify
end