require_relative 'item'

class Serializer
  def self.item
    Item.new
  end

  def self.collection
  end

  def item
    self.class.item
  end
end

