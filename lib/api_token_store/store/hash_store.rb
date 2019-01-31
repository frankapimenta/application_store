require 'forwardable'
require_relative '../refinements/hash'
require_relative 'general_store'

module ApiTokenStore
  class HashStore < GeneralStore
    using ApiTokenStore::Refinements
    extend Forwardable
    include Enumerable
    def_delegators :store, :clear, :empty?, :has_key?, :to_hash

    def initialize store=Hash.new
      # TODO: hash or hash with indeferent access else raise
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

  end
end
