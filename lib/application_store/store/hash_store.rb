require 'forwardable'
require_relative '../refinements/hash'
require_relative 'general_store'

module ApplicationStore
  class HashStore < GeneralStore
    using Refinements
    extend Forwardable
    include Enumerable
    def_delegators :store, :clear, :empty?, :has_key?, :to_hash

    def initialize store=Hash.new
      # TODO: hash or hash with indeferent access else raise
      super
    end

    def method_missing method, *args, &block
      is_writter?(method) ? set(method[0...-1].to_sym, args.pop) : get(method.to_sym)
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

    private def is_writter? method_name
      method_name.to_s.chars.last == "="
    end

  end
end
