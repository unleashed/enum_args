module EnumArgs
  def self.included(base)
    base.prepend ProxiedEnumerable
  end

  module ProxiedEnumerable
    module ClassMethods
      def enum_method
        @enum_method ||= :iterator
      end

      def enum_accessor_method
        @enum_accessor_method ||= :enum_args
      end

      def enum_default_args
        @enum_default_args ||= []
      end

      def enum_default_using
        @enum_default_using ||= {}
      end

      def enum_args_for(method, *args, using: {}, with_enum_as: :enum_args)
        @enum_method = method
        @enum_default_args = args
        raise TypeError, "expected Hash, found #{using.class}" unless using.is_a? Hash
        @enum_default_using = using
        @enum_accessor_method = with_enum_as
      end
    end

    def self.prepended(base)
      # including Enumerable is just so that obj#is_a? Enumerable returns true
      base.include Enumerable
      base.singleton_class.prepend ClassMethods
    end

    def self.on_enumerable_methods(on, &blk)
      (Enumerable.instance_methods + [:each]).each do |m|
        on.send :define_method, m, &blk
      end
    end

    on_enumerable_methods self do |*args, &blk|
      send(self.class.enum_accessor_method).send __method__, *args, &blk
    end

    def initialize(*args, &blk)
      @enum_args = EnumArgs::Proxy.new self, self.class.enum_method, *self.class.enum_default_args, using: self.class.enum_default_using
      define_singleton_method(self.class.enum_accessor_method) do
        instance_variable_get('@enum_args')
      end
      super
    end
  end
end
