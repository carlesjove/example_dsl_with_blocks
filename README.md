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

Now we get this new error message:

`'href': wrong number of arguments (1 for 0) (ArgumentError)`

We're progressing, cause this means that, effectively, we've passed the block to
`Item`. So maybe now we should edit `Item#href` to take arguments and just
return them:

```ruby
class Item
  def href(*args)
    args
  end
end
```

Let's run the tests. And, :sweat_smile:

`ArgumentError: wrong number of arguments (0 for 1..3)`

What the hell is this? Let's look at the rest of the message:

```bash
/Users/carles/code/os/example_dsl_with_blocks/serializer.rb:6:in `instance_eval'
/Users/carles/code/os/example_dsl_with_blocks/serializer.rb:6:in `item'
/Users/carles/code/os/example_dsl_with_blocks/serializer.rb:13:in `item'
test/test.rb:13:in `test_that_item_has_href'
```

Ok, so it seems that the error message is related to `instance_eval` in some
way, but the last line says `serializer.rb:13`. So let's look what's going on
over there.

```ruby
# serializer.rb:13
def item
  self.class.item # this line
end
```

I see! At the very beginning of the process we thought that we'd get the data of
out the class method, but now `self.item` takes a block as an argument, and
passes it to `instance_eval`. That's what this error message is telling us:
you're calling a method without the arguments it needs to be able to call
`instance_eval`.

Things have changed a little bit, so maybe we should try another strategy.

It's obvious that we must change line 13, since it doesn't make any sense to run
a method called there. Maybe the `Item` instance could be a class variable and
this could be returned by `Serializer#item`. A practical way to do so is by
using Ruby's `attr_accessor`, which will set both a read and write method (a
getter and a setter) for this. Since we want it to be a class variable, we can
use the convenient `class << self` construct.

```ruby
class Serializer
  class << self
    attr_accessor :_item
  end

  def self.item(&block)
    @_item = Item.new
    @_item.instance_eval(&block)
  end

  # …

  def item
    self.class._item
  end
end
```

Run the tests again, and the output resembles a lot to one we got earlier:

```bash
Expected: ["item-href"]
  Actual: []
```

Yeah! Seems we're back on the right track. But why are we getting an empty
array? Aren't we collecting the arguments and giving them back? Not exactly.
We're getting them (all of them, no matter how many of them, thanks to the splat
operator, \*). But notice that since `href` is a method, when we're trying to
retrieve the value of `href` with `@serializer.item.href` we're really _calling_ the method, but this time
with no arguments at all, and hence the empty array. In order to prevent later
calls to return an empty array, we can:

```ruby
class Item
  def href(*args)
    @href ||= args
  end
end
```

`@href ||= args` means: if `@href` is not set already, set it and fill it with
`args`. If it is set, return its value.

Run the tests again, and… :tada: :tada: :tada: It passes. Godd job!
