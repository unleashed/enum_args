require 'fiber'

module EnumArgs
  class Enumerator
    include Enumerable

    attr_reader :object, :method_name, :args, :using, :yield_handler

    DEFAULT_YIELD_HANDLER = ->(*yielded_values) do
      Fiber.yield(*yielded_values)
    end

    def args=(args)
      @args = args
      @args << using unless using.empty?
      @args
    end

    def using=(using)
      @using = using
      self.args = args
      @using
    end

    def initialize(object, method_name, *fixed_args, using: {}, &yield_handler)
      @object = object
      @method_name = method_name
      @using = using # don't use self.using=() here, since we can't call it yet
      self.args = fixed_args
      @yield_handler = yield_handler || DEFAULT_YIELD_HANDLER
      rewind
    end

    def each
      return enum_for(:each) unless block_given?
      # loop does actually get broken by StopIteration
      loop do
        yield self.next
      end
      object
    end

    def rewind
      self.fiber = Fiber.new do
        object.send method_name, *args, &yield_handler
        raise StopIteration
      end
      self
    end

    def next
      rewind unless fiber.alive?
      fiber.resume
    end

    private

    attr_accessor :fiber
  end

  private_constant :Enumerator
end
