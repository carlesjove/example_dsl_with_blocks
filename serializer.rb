require_relative 'item'
require_relative 'collection'

class Serializer
  class << self
    attr_accessor :_item
    attr_accessor :_collection
  end

  def self.item(&block)
    @_item = Item.new
    @_item.instance_eval(&block)
  end

  def self.collection(&block)
    @_collection = Collection.new
    @_collection.instance_eval(&block)
  end

  def item
    self.class._item
  end

  def collection
    self.class._collection
  end
end

