# Add popular hashing functions to strings.
# Then wrap in a nice hashify method.
class String
  require 'digest/md5'
  
  VALID_FORMATS = [:md5, :sha1, :sha2]
  
  def hashify(format = :md5)
    eval("to_#{format}") if VALID_FORMATS.include?(format)
  end
  
  def to_md5
    Digest::MD5.hexdigest(self)
  end
  
  def to_sha1
    Digest::SHA1.hexdigest(self)
  end
  
  def to_sha2
    Digest::SHA2.hexdigest(self)
  end
  
end