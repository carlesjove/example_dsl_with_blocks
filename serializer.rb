require_relative 'item'

class Serializer
  def self.item(&block)
    i = Item.new
    i.instance_eval(&block)
  end

  def self.collection
  end

  def item
    self.class.item
  end
end

