require 'minitest/autorun'
require_relative 'user_serializer'

class TestDsl < Minitest::Test
  def setup
    @serializer = UserSerializer.new
  end

  def test_that_item_has_href
    assert_equal ["item-href"], @serializer.item.href
  end

  def test_that_collection_has_href
    assert_equal ["collection-href"], @serializer.collection.href
  end
end

