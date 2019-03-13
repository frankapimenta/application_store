# TODO: solve issue with #set and #get for non symbol keys
module ApplicationStore
  class GeneralStore
    attr_reader :store

    def initialize store
      raise StandardError.new "a store must be set for the store" if store.nil?

      @store = store
    end

    def method_missing method, *args, &block
      is_writter?(method) ? set(method[0...-1].to_sym, args.pop) : get(method.to_sym)
    end

    def each &block
      block_given? ? @store.each(&block) : @store.to_enum
    end

    def get key
      raise NotImplementedError.new "implement method in child class"
    end

    def set key, value
      raise NotImplementedError.new "implement method in child class"
    end

    def unset key
      raise NotImplementedError.new "implement method in child class"
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
