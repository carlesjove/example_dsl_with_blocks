Example DSL With Blocks
=======================

Start with the design we'd like to implement and a failing test for it.

Run the tests, and we get:

```bash
uninitialized constant Serializer (NameError)
```

I create a class named `Serializer`, include it in the tests' file, and run them
again. Now it yells:

```bash
undefined method `item' for UserSerializer:Class (NoMethodError)
```

The first thing we need to think about now is: do we need `#item` to be a class or an
instance method? Or both? In the tests we're using an instance method, so let's
start by writing this first.

```ruby
class Serializer
  def item
  end
end
```

Run the tests again, an we still get the exact same error message.

Ok, this _can't_ be accomplished. Go home and start thinking about opening a pub.
People love drinking. I could make good money on this.

Wait! The error message ends with `UserSerializer:Class`. I hadn't noticed this
`:Class`. Let's try moving `#item` to a class method:

```ruby
class Serializer
  def self.item
  end
end
```

Run the tests again, and…

```bash
undefined method `collection' for UserSerializer:Class (NoMethodError)
```

Yeah! We moved forward. Now let's do exactly the same for the `#collection`
method.

```ruby
class Serializer
  def self.item
  end

  def self.collection
  end
end
```

Run the tests again, and great!, we get completely different errors.

Before writing more code, however, I need to fix something first. I
wrote two tests at the beginning, and this is not a great idea. It's better to
write and pass one test at a time. So let's skip the `#collection` test, by now. MiniTest has a convenient method for this situation,
`skip`. Let's use it:

```ruby
def test_that_collection_has_href
  skip
  assert_equal ["collection-href"], @serializer.collection.href
end
```

Run the tests again, and we get this output:

```bash
2 runs, 0 assertions, 0 failures, 1 errors, 1 skips
```

Great, out second test has been skipped.

The current error message goes:

```bash
NoMethodError: undefined method `collection' for #<UserSerializer:0x007fd51ca46408>
```

See the `#<UserSerializer>` part? This means an instance method is missing.
Let's add it:

```ruby
class Serializer
  # ...

  def item
  end
end
```

The error message now goes:

```bash
NoMethodError: undefined method `href' for nil:NilClass
```

`nil:NilClass` is one of those things you'll see every now and then in Ruby
error messages. `Nil` is Ruby's default for nothingness, and it can either mean
that something does not exist, or that if it exists it is absolutely empty. Not
empty as `"  "`, but empty as `   `.

In this particular situation, the error message translates to "You are calling
`href` on nothing", and "nothing" here is `item` on `@serializer.item`. It makes
sense, since the instance method `#item` doesn't return anything, which in Ruby
means that it returns `nil` (which is, actually, an instance of the `Nil`
class). Ruby.

What we'd really like is `@serializer.item.href` to return `"item-href"`, but
first we need to collect it somehow. Remember that our first failing test was
fixed by adding the class method `#item`? This means that _this_ method, and not
the instance's, runs first. So maybe we need to start there.

From our design, what we really want to have is an `item` object within
`@serializer`, and we want to be able to call methods on it. So we need `item`
to be an object. Let's write an `Item` class and instantiate it in the `#item`
class method.

```ruby
# item.rb
class Item
end

# serializer.rb
require_relative 'item'

class Serializer
  # …
  def self.item
    Item.new
  end
  # …
end
```

Run the tests again, and we run into:

```bash
uninitialized constant Serializer::Item (NameError)
```

It was expected that `Item` belonged to the namespace `Serializer`. Makes sense,
since we'll be using `Item` in the context of `Serializer`. Let's put it in its
namespace:

```ruby
# item.rb
class Serializer
  class Item
  end
end
```

Run the tests again and it says:

`NoMethodError: undefined method `href' for nil:NilClass`

`@serializer.item.href` at the test is calling `href` on the instance method
`#item`, not the class method, so we need to return something there. We'll just
return what we get from `self.item`.

```ruby
class Serializer
  # …
  def item
    self.class.item
  end
  # …
end
```

Now, if we run the tests again, we get a new error:

```bash
NoMethodError: undefined method `href' for #<Serializer::Item:0x007f90c340a190>
```

Let's fix this by adding an `href` method to `Item`.

```ruby
class Serializer
  class Item
    def href
    end
  end
end
```

The output if we run the tests again is:

```bash
Expected: ["item-href"]
  Actual: nil
```

Cool! We've been looking for this all the way long. So far, failing tests'
messages have been guiding us. Now, however, we need to figure out by ourselves how to get
`Item.href` to return what we expect.

If we look at our initial design, `item` is a block. However, `Serializer#item`
is not getting the block. So let's start by using the block:

```ruby
class Serializer
  def self.item(&block)
    i = Item.new
    i.instance_eval(&block)
  end
end
```

See what I've done? The `self.item` method takes a block as its only arguments,
then we instantiate an `Item`, and call `instance_eval` on it. In plain english,
what is happening here is that the block itself is being passed to the `Item` instance
and evaluated within its context. Even more explicit: the instance of `Item`
will get `href "item-href"` and evaluate it.
