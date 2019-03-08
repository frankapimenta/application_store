require 'forwardable'
require 'request_store'

module ApplicationStore
  class GlobalStore < GeneralStore
    using Refinements
    extend Forwardable
    include Enumerable
    def_delegators :store, :empty?, :has_key?

    def initialize store: ::RequestStore.store
      super store
    end

    def get key
      store.fetch key, nil
    end

    def set key, value
      store[key] = value
    end

    def unset key
      store.delete key
    end

    def clear
      store.clear
    end

    def traverse(&block)
      store.traverse(&block)
    end

    def to_hash
      store
    end

  end
end
