require 'forwardable'
require_relative 'hash_store'

module ApplicationStore
  class Store < GeneralStore
    extend Forwardable
    include Parenthood
    def_delegators :store, :get, :set, :unset, :clear, :to_hash

    def initialize store= HashStore.new, name: nil, parent: nil
      super store, parent: parent
      self.name = name.to_sym unless name.nil?
    end

    def name
      get :name
    end

    def name= name
      old_name, new_name = self.name, name.to_sym

      set :name, new_name

      unless parent.nil?
        self.parent.set(new_name, self)
        self.parent.unset(old_name)
      end
    end

  end
end
