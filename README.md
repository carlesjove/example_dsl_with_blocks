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


