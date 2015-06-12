class Helpers
  def self.get_methods_returning_enumerator_for(obj)
    mm = []
    (Enumerable.instance_methods - Object.new.methods).map do |m|
      args = []
      blk = nil
      begin
        obj.send(m, *args, &blk).tap do |res|
          mm << [m, args, blk] if res.is_a?(Enumerator)
          # clean call data before next loop
          blk = nil
          args = []
        end
      rescue ArgumentError => e
        if e.message =~ /no block given/ || e.message =~ /without a block/
          # method required block
          blk = lambda {}
        else
          # argument error, let's try with a Fixnum
          args << 2
        end
        retry
      rescue TypeError => e
        # switch argument types, Fixnum <=> Symbol, nothing => Symbol
        a = args.pop
        args << case a
        when Symbol
          2
        else
          :each
        end
        retry
      rescue NoMethodError
        # next
      end
    end
    mm
  end
  private_class_method :get_methods_returning_enumerator_for

  def self.call_description(m, args, blk, n = nil)
    r = "#{m}(#{args.map(&:class).join(', ') if args && !args.empty?})#{' { ... }' if blk}"
    if n
      r + '.' + call_description(*n)
    else
      r
    end
  end

  ENUMERABLE_METHODS = get_methods_returning_enumerator_for([])
  ENUMERATOR_METHODS = get_methods_returning_enumerator_for([].each)
  ENUMERATOR_LAZY_METHODS = get_methods_returning_enumerator_for([].lazy)

  # Example classes that help test the different integration possibilities
  class IncludeEnumArgs
    include EnumArgs

    enum_args_for :my_iterator, 27, using: {config: 'this', resumeinfo: 'way'},
      with_enum_as: :enum_with_args

    def initialize
      # do nothing
    end

    def my_iterator(stride = 10, config: nil, resumeinfo: nil)
      yield 1
      yield 2
      yield 3
      yield 4
    end
  end

  class EnumArgsUser
    attr_reader :enum_args

    def initialize
      @enum_args = EnumArgs::Proxy.new self, :my_iterator, 27, using: { config: 'this', resumeinfo: 'way' }
    end

    # undef Kernel#select as it will shadow Enumerable#select
    undef_method :select

    def my_iterator(stride = 10, config: nil, resumeinfo: nil)
      yield 1
      yield 2
      yield 3
      yield 4
    end

    def method_missing(m, *args, &blk)
      @enum_args.send m, *args, &blk
    end

    def respond_to_missing?(m, include_all = false)
      @enum_args.respond_to?(m, include_all)
    end
  end
end
