require 'forwardable'
require_relative 'hash_store'

module ApplicationStore
  class Store < GeneralStore
    extend Forwardable
    def_delegators :@store, :get, :set, :unset, :clear, :to_hash

    def initialize store= HashStore.new, name: nil, parent: nil
      super store, parent: parent
      self.name       = name.to_sym unless name.nil?
    end

    def name
      get :name
    end

    def name= name
      set :name, name.to_sym
    end

  end
end
