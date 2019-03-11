require 'forwardable'
require 'request_store'

module ApplicationStore
  class GlobalStore < GeneralStore
    using Refinements
    extend Forwardable
    include Enumerable
    def_delegators :store, :clear, :empty?, :has_key?

    def initialize store= ::RequestStore.store
      super
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

    def traverse(&block)
      store.traverse(&block)
    end

    def to_hash
      store
    end

  end
end
