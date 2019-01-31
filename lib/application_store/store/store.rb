require 'forwardable'

module ApplicationStore
  class Store < GeneralStore
    extend Forwardable
    def_delegators :@store, :get, :set, :unset, :clear, :to_hash

    def initialize store= HashStore.new, name: nil
      super store
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
