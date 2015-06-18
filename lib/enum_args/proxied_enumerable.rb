module EnumArgs
  def self.included(base)
    base.prepend ProxiedEnumerable
  end

  module ProxiedEnumerable
    module ClassMethods
      METHODS = [:enum_args_method, :enum_args_accessor_method,
                 :enum_args_default_args, :enum_args_default_using]

      def enum_args_method
        @enum_args_method ||= :iterator
      end

      def enum_args_accessor_method
        @enum_args_accessor_method ||= :enum_args
      end

      def enum_args_default_args
        @enum_args_default_args ||= []
      end

      def enum_args_default_using
        @enum_args_default_using ||= {}
      end

      def enum_args_for(method, *args, using: {}, with_enum_args_as: :enum_args)
        @enum_args_method = method
        @enum_args_default_args = args
        raise TypeError, "expected Hash, found #{using.class}" unless using.is_a? Hash
        @enum_args_default_using = using
        @enum_args_accessor_method = with_enum_args_as
      end

      me = self # bound variable for the :inherited block

      define_method :inherited do |klass|
        klass.singleton_class.prepend me
        METHODS.each do |m|
          klass.instance_variable_set("@#{m}", send(m))
        end
        super(klass)
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
      send(self.class.enum_args_accessor_method).send __method__, *args, &blk
    end

    def initialize(*args, &blk)
      klass = self.class
      name = klass.enum_args_accessor_method
      instance_variable_set(
        "@#{name}",
        EnumArgs::Proxy.new(self, klass.enum_args_method, *klass.enum_args_default_args,
                            using: klass.enum_args_default_using)
      )
      define_singleton_method(name) do
        instance_variable_get("@#{name}")
      end
      super
    end
  end
end
