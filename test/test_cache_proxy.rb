require 'helper'

class CacheProxyTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def test_fetch_method
    assert_equal "hi", CacheProxy.new.fetch {"hi"}
  end
end