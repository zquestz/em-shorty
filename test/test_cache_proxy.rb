require 'helper'

class CacheProxyTest < Test::Unit::TestCase
  
  def test_fetch_method
    assert_equal 'hi', CacheProxy.new.fetch {'hi'}
  end
  
  def test_flush_method
    assert_nil CacheProxy.new.flush
  end

end