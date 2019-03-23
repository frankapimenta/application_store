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

    def traverse(&block)
      store.traverse(&block)
    end

    def to_hash
      store
    end

  end
end
