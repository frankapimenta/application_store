require 'forwardable'
require 'request_store'

# GLOBAL STORES HAVE NO PARENTS BECAUSE THEY ARE ROOT
module ApplicationStore
  class GlobalStore < GeneralStore
    using Refinements
    extend Forwardable
    include Enumerable, Parenthood
    def_delegators :store, :clear, :empty?, :has_key?

    def initialize store= ::RequestStore.store, parent: nil
      super
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

    def traverse(&block)
      store.traverse(&block)
    end

    def to_hash
      store
    end

  end
end
