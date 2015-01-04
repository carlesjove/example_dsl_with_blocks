require_relative 'item'

class Serializer
  class << self
    attr_accessor :_item
  end

  def self.item(&block)
    @_item = Item.new
    @_item.instance_eval(&block)
  end

  def self.collection
  end

  def item
    self.class._item
  end
end

