module ApplicationStore
  class GeneralStore
    attr_reader :store, :parent

    def initialize store, parent: nil
      raise StandardError.new "a store must be set for the store" if store.nil?
      @store, @parent = store, parent
    end

    def method_missing method, *args, &block
      is_writter?(method) ? set(method[0...-1].to_sym, args.pop) : get(method.to_sym)
    end

    def parent= parent
      raise NotImplementedError.new "implement method in child class"
    end

    def each &block
      block_given? ? @store.each(&block) : @store.to_enum
    end

    def get key
      store.fetch key.to_sym, nil
    end

    def set key, value
      store[key.to_sym] = value
    end

    def unset key
      store.delete key.to_sym
    end

    def clear
      raise NotImplementedError.new "implement method in child class"
    end

    def count
      raise NotImplementedError.new "implement method in child class"
    end

    def empty?
      raise NotImplementedError.new "implement method in child class"
    end

    def has_key? key
      raise NotImplementedError.new "implement method in child class"
    end

    def to_hash
      raise NotImplementedError.new "implement method in child class"
    end

    def traverse
      raise NotImplementedError.new "implement method in child class"
    end

    private def is_writter? method_name
      method_name.to_s.chars.last == "="
    end

  end
end
