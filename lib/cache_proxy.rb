# Simple way to turn the cache on and off
# and keep your code clean.
class CacheProxy

  def fetch(*args, &block)
    block.call
  end

  def flush(*args)
  end
  
end