module EnumArgs
  class NaiveCache
    def call(object, method_name, args, using, create)
      @cache ||= {}
      @cache[[object, method_name, args, using]] ||= create.call(object, method_name, args, using)
    end
  end
end
