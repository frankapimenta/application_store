require 'forwardable'
require 'application_store/store/store'
require 'application_store/store/hash_store'
require 'application_store/store/global_store'

#TODO: modify the parent from self to store
module ApplicationStore
  class StoreComposite < GeneralStore
    include Parenthood
    extend Forwardable
    attr_reader :name
    def_delegators :store, :get, :set, :unset, :count, :empty?, :has_key?

    def initialize global_store: GlobalStore.new, internal_store: HashStore.new, name: 'default'
      super global_store
      @name = "__#{name}__store__".to_sym
      @store.set @name, internal_store

      # tells if store was destroyed and so makes it unusable anymore
      @destroyed = false
    end

    def destroyed?
      @destroyed
    end

    def rename name
      old_name, current_store = @name, store
      @name                   = name.to_sym

      @store.set @name, current_store
      @store.unset old_name
    end

    def add application_store, force: false
      unless application_store.parent == self
        unless force || get(application_store.name.to_sym).nil?
          raise StandardError, "a store with same name already exists"
        else
          if force
            old_store        = self.get(application_store.name)
            old_store_parent = old_store.parent
            old_store_parent.unset(old_store.name)
            old_store.parent = nil
          end
          application_store.parent = self.store
          set application_store.name, application_store

          application_store
        end
      end
    end

    def remove application_store
      raise StandardError, "application does not exist in the store" unless get(application_store.name)
      application_store.parent = nil
      store.unset application_store.name
    end

    def create name:
      add Store.new name: name
    end

    def clear
      @store.set @name, HashStore.new
    end

    def destroy!
      @store.clear
      @destroyed = true
    end

    def hashify_store
      store.traverse { |k,v| [k,v] }
    end

    def to_hash
      {:"#{@name}" => hashify_store }
    end

    def store
      raise StandardError.new "this store is destroyed and cannot be used anymore!" if destroyed?

      @store.get(@name)
    end
  end
end
