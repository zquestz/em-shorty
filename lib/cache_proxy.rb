class CacheProxy

  def fetch(*args, &block)
    block.call
  end
  
end