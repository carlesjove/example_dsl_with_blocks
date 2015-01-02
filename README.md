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

