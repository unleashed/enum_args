[![Gem Version](https://badge.fury.io/rb/enum_args.svg)](http://badge.fury.io/rb/enum_args) [![Build Status](https://travis-ci.org/unleashed/enum_args.svg?branch=master)](https://travis-ci.org/unleashed/enum_args) [![Code Climate](https://codeclimate.com/github/unleashed/enum_args/badges/gpa.svg)](https://codeclimate.com/github/unleashed/enum_args) [![Test Coverage](https://codeclimate.com/github/unleashed/enum_args/badges/coverage.svg)](https://codeclimate.com/github/unleashed/enum_args)

# EnumArgs

EnumArgs is a simple gem that enables your enumerators to receive parameters
from any of the methods provided by Enumerable in a uniform fashion, so that you
could, ie. `ai_team.select(max_cpu: 80) { |troop| troop.can_hit?(enemy) }.each
{ ... }`.

See Usage for some examples.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'enum_args'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install enum_args

## Usage

You can run `bin/console` for an interactive prompt. See an example:

Imagine you had a collection of items for which you'd want to iterate over
depending on some specified parameters, such as some pausing between yielding
elements because the actual source of them somehow rate-limits you.

```ruby
class MyCollection
  include Enumerable

  def initialize(*elements)
    @ary = elements # imagine this is somehow an external source of elements
  end

  def each(pause = 1, verbose = false)
    return enum_for(:each, pause, verbose) unless block_given?
    ary.each do |element|
      yield element
      puts "sleeping for #{pause} secs" if verbose
      sleep pause # now sleep a little bit to not hog the source of elements
    end
  end

  # [...]

  private

  attr_reader :ary
end
```

To use this class, you can do the following:

```ruby
collection = MyCollection.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
enumerator = collection.each(2, true)
enumerator.each do |element|
  puts "I got #{element}, and now I should sleep for a couple secs"
end
```

The only bad smell is that, somehow, even though you had a collection, you
needed to get an external enumerator out of it to start getting elements. It is
not exactly ergonomic. But what happens if I wanted to suddenly increase the
pause time used to 5 secs?

```ruby
enumerator.each(10) do |element|
  puts "This does not quite work"
end
```

Well, we could do better, see:
```ruby
collection.each(5) do |element|
  puts "This does work indeed!"
end
```

Cool! We could change the pause right away, and without having to go through the
whole process again... Except you'll soon discover this:

```ruby
# won't work :(
collection.select(5) do |element|
  element.odd?
end
```

Doing that requires to go back and get the external enumerator again:
```ruby
collection.each(5).select do |element|
  element.odd?
end
```

What this gem does present the user of your collection a uniform layer in which
they can call any Enumerable method with the options they wish to pass to your
enumerator. See how would we implement this example:

```ruby
class MyCollection
  include EnumArgs

  # use iterator to yield elements, and let it be configured with one fixed
  # parameter, and two configurable parameters (inside `using`).
  enum_args_for :iterator, '[INFO] ', using: { pause: 1, verbose: false }

  def initialize(*elements)
    @ary = elements
  end

  # [...]

  private

  def iterator(message = '', pause:, verbose: false)
    ary.each do |element|
      yield element
      puts "#{message}sleeping for #{pause} secs" if verbose
      sleep pause
    end
  end

  attr_reader :ary
end
```

Now you could do:

```
collection = MyCollection.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
collection.select(pause: 2, verbose: true) do |element|
  element.odd?
end
collection.each(pause: 3) do |element|
  puts "Dealing with #{element} and sleeping for 3 secs :)"
end
# add 1 to each number and print it, lazily
collection.lazy(pause: 4, verbose: true).map do |element|
  element + 1
end.each do |element|
  puts element
end
```

In fact, you can use all of the awesomeness of Enumerable, noting that the
parameters specified (at least those that can vary) should be keyword arguments
present in the above declaration.

You can still create external enumerators, chain Enumerable methods, and do all
sorts of magic. The caveat is that the first Enumerable method will be the only
one accepting the parameters, and they will be ignored if not declared with
a default value in `enum_args_for`.

Including this gem's module in your class will add some class and instance
methods. The instance method you will get is `enum_args`, which is the actual
enumerator that will use your iterator method.

If that bothers you, you can change it by specifiyng a different symbol to
`enum_args_for` using the `with_enum_as: :your_symbol` keyword argument.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unleashed/enum_args.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

