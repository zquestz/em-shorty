require 'helper'

class TestHashify < Test::Unit::TestCase
  
  @@matchers = ['hi', ['hi'], [:hi], {'hi' => 'hi'}, {:hi => 'hi'}, {'hi' => :hi}]

  def test_to_md5
    for matcher in @@matchers
      assert_equal Digest::MD5.hexdigest(matcher.to_s), matcher.to_md5
    end
  end
  
  def test_to_sha1
    for matcher in @@matchers
      assert_equal Digest::SHA1.hexdigest(matcher.to_s), matcher.to_sha1
    end
  end
  
  def test_to_sha2
    for matcher in @@matchers
      assert_equal Digest::SHA2.hexdigest(matcher.to_s), matcher.to_sha2
    end
  end
  
  def test_hashify_string_default_sha1
    assert_equal 'hi'.hashify, 'hi'.hashify(:sha1)
  end
  
  def test_hashify_string_default_hash_setter
    String.default_hash = :md5
    assert_equal 'hi'.hashify, 'hi'.hashify(:md5)
    String.default_hash = :sha1
  end
  
  def test_hashify_array_default_sha1
    assert_equal ['hi'].hashify, ['hi'].hashify(:sha1)
  end
  
  def test_hashify_array_default_hash_setter
    Array.default_hash = :md5
    assert_equal ['hi'].hashify, ['hi'].hashify(:md5)
    Array.default_hash = :sha1
  end
  
  def test_hashify_hash_default_sha1
    assert_equal ({'hi' => 'hi'}.hashify), ({'hi' => 'hi'}.hashify(:sha1))
  end
  
  def test_hashify_hash_default_hash_setter
    Hash.default_hash = :md5
    assert_equal ({'hi' => 'hi'}.hashify), ({'hi' => 'hi'}.hashify(:md5))
    Hash.default_hash = :sha1
  end
  
  def test_hashify_string_md5
    for matcher in @@matchers
      assert_equal Digest::MD5.hexdigest(matcher.to_s), matcher.hashify(:md5)
    end
  end
  
  def test_hashify_string_sha1
    for matcher in @@matchers
      assert_equal Digest::SHA1.hexdigest(matcher.to_s), matcher.hashify(:sha1)
    end
  end
  
  def test_hashify_string_sha2
    for matcher in @@matchers
      assert_equal Digest::SHA2.hexdigest(matcher.to_s), matcher.hashify(:sha2)
    end
  end
  
  def test_any_class_with_to_s_hashify
    assert_equal Class.new { include Hashify; def to_s; 'val'; end }.new.hashify, Digest::SHA1.hexdigest('val')
  end
  
  def test_hashify_invalid
    for matcher in @@matchers
      assert_nil matcher.hashify(:error)
    end
  end
  
end