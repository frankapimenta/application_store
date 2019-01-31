require 'forwardable'

module ApplicationStore
  class Store < GeneralStore
    extend Forwardable
    def_delegators :@store, :get, :set, :unset, :clear, :to_hash

    def initialize store= HashStore.new, name: nil, encryption: nil, secret: nil
      super store
      self.name       = name.to_sym unless name.nil?
      self.encryption = encryption  unless encryption.nil?
      self.secret     = secret      unless secret.nil?
    end

    def name
      get :name
    end

    def name= name
      set :name, name.to_sym
    end

    def encryption
      get :encryption
    end

    def encryption= encryption
      set :encryption, encryption
    end

    def secret
      get :secret
    end

    def secret= secret
      set :secret, secret
    end

    def valid? encryption: false
      return !name.nil? unless encryption
      # a ApplicationStore instance is valid when ready for possible encryption
      !(name.nil? || encryption.nil? || secret.nil?)
    end

  end
end
