require 'forwardable'
require_relative '../refinements/hash'
require_relative 'general_store'

module ApplicationStore
  class HashStore < GeneralStore
    using Refinements
    extend Forwardable
    include Enumerable, Parenthood
    def_delegators :store, :clear, :empty?, :has_key?

    def initialize store=Hash.new, parent: nil
      # TODO: hash or hash with indeferent access else raise
      super
    end

    def traverse(&block)
      store.traverse(&block)
    end

    def to_hash
      traverse { |k,v| [k, v] }
    end
  end
end
