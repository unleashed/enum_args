module EnumArgs
  class Proxy
    ProxiedEnumerable.on_enumerable_methods self do |*args, **options, &blk|
      enum_delegate __method__, args, options, blk
    end

    def self.attr_writer_resetting_enum(*writers)
      writers.each do |w|
        define_method "#{w}=" do |val|
          instance_variable_set("@#{w}", val).tap do
            reset_default_enum
          end
        end
      end
    end
    private_class_method :attr_writer_resetting_enum

    attr_reader :enum, :object, :method_name, :args, :using
    attr_writer_resetting_enum :object, :method_name, :args, :using

    def initialize(object, method_name, *args, using: {})
      @object = object
      @method_name = method_name
      @args = args
      @using = using
      reset_default_enum
    end

    private

    attr_writer :enum

    def enum_delegate(m, m_args, options, blk)
      # remove specific 'using' options from method call
      iterator_params = extract_iterator_params_from options

      m_args << options unless options.empty?
      e = if iterator_params.empty?
            # no changes, use default enumerator
            enum
          else
            build_enum(iterator_params)
          end
      e.send m, *m_args, &blk
    end

    def extract_iterator_params_from(options)
      using.inject({}) do |acc, (k, _)|
        val = options.delete k
        acc[k] = val if val
        acc
      end
    end

    def reset_default_enum
      raise TypeError, "expected Hash, found #{using.class}" unless using.is_a? Hash
      self.enum = build_enum
    end

    def build_enum(merge = {})
      Enumerator.new(object, method_name, *args, using: self.using.merge(merge))
    end
  end
end
