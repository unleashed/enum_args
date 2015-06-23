module EnumArgs
  class Proxy
    ProxiedEnumerable.on_enumerable_methods self do |*args, **options, &blk|
      enum_delegate __method__, args, options, blk
    end

    attr_accessor :object, :method_name, :args
    attr_reader :using

    def initialize(object, method_name, *args, using: {})
      @object = object
      @method_name = method_name
      @args = args
      self.using = using
    end

    def using=(using)
      raise TypeError, "expected Hash, found #{using.class}" unless using.is_a? Hash
      @using = using
    end

    private

    attr_writer :enum

    def enum_delegate(m, m_args, options, blk)
      # remove specific 'using' options from method call
      iterator_params = extract_iterator_params_from options

      m_args << options unless options.empty?
      build_enum(iterator_params).send m, *m_args, &blk
    end

    def extract_iterator_params_from(options)
      using.inject({}) do |acc, (k, _)|
        val = options.delete k
        acc[k] = val if val
        acc
      end
    end

    def build_enum(merge = {})
      Enumerator.new(object, method_name, *args, using: self.using.merge(merge))
    end
  end
end
