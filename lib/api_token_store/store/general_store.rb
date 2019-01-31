module ApiTokenStore
  class GeneralStore
    attr_reader :store

    def initialize store
      raise StandardError.new "a store must be set for the store" if store.nil?

      @store = store
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

  end
end
