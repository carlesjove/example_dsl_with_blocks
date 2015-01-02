require 'minitest/autorun'
# I'll keep using `require_relative` for the example,
# just so I don't have deal with the path
require_relative '../serializer'
require_relative 'user_serializer'

class TestDsl < Minitest::Test
  def setup
    @serializer = UserSerializer.new
  end

  def test_that_item_has_href
    assert_equal ["item-href"], @serializer.item.href
  end

  def test_that_collection_has_href
    skip
    assert_equal ["collection-href"], @serializer.collection.href
  end
end

