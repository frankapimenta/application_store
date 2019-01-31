require 'forwardable'
require 'application_store/store/store'
require 'application_store/store/hash_store'
require 'application_store/store/global_store'

module ApplicationStore
  class StoreComposite < GeneralStore
    extend Forwardable
    attr_reader :name
    def_delegators :store, :get, :set, :unset, :count, :empty?, :has_key?

    def initialize global_store: GlobalStore.new, internal_store: HashStore.new, name: nil
      super global_store
      # TODO: why here explicity defined HashStore?
      @name = name.nil? ? :__api_token_auth__default__store__ : "__api_token_auth__#{name}__store__".to_sym
      @store.set @name, internal_store
    end

    def rename name
      old_name, current_store = @name, store
      @name                   = name.to_sym

      @store.set @name, current_store
      @store.unset old_name
    end

    def add application_store, force: false
      unless force || get(application_store.name.to_sym).nil?
        raise StandardError, "there is already an application with the same name in the store"
      else
        set application_store.name, application_store
      end
    end

    def remove application_store
      raise StandardError, "application does not exist in the store" unless get(application_store.name)
      store.unset application_store.name
    end

    def create name:
      add Store.new name: name
    end

    def clear
      @store.set @name, HashStore.new
    end

    def hashify_store
      store.traverse { |k,v| [k,v] }
    end

    def to_hash
      {:"#{@name}" => hashify_store }
    end

    def store
      @store.get(@name)
    end
  end
end
