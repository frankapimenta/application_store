# TODO: check #count on #store for empty store
require "application_store/version"
require "application_store/modules/parenthood"

module ApplicationStore

  def rails_app
    raise StandardError.new "you are not within a Rails application" unless Object.const_defined?(:Rails)

    ApplicationStore::RailsApplication.new(Rails.application)
  end


  def root_path
    return ENV['APPLICATION_STORE_ROOT_PATH'] if ENV['APPLICATION_STORE_ROOT_PATH']

    return Rails.root if Object.const_defined? :Rails

    raise StandardError.new "you must defined env var APPLICATION_STORE_ROOT_PATH when not in a Rails app"

  end

  def store
    @store ||= StoreComposite.new
  end

  def rename name
    store.rename name
    { "#{name}" => store.store }
  end

  def config environment: Config.environment, file_name: 'application_store.yml'
    Config.new environment: environment, file_name: file_name
  end

  def content environment: Config.environment, file_name: 'application_store.yml'
    content = config(environment: environment, file_name: file_name).content(environment: environment)

    yield content if block_given?

    content
  end

  def reset!
    @store = nil
  end

  def run! environment: Config.environment, file_name: 'application_store.yml'
    content(environment: environment, file_name: file_name) do |content|
      nested_store(store, content)
    end
  end

  # support function that should be private but is not
  def nested_store store, hash
    hash.each_pair do |key,hsh|
      if hsh.is_a?(Hash)
        new_store = Store.new(name: key, parent: store)
        nested_store(new_store, hsh)

        store.set key.to_sym, new_store
      else
        store.set key.to_sym, hsh
      end
    end
    store
  end

  module_function :rails_app, :root_path, :store, :rename, :config, :content, :reset!, :run!, :nested_store
end

require_relative 'application_store/config'
require_relative 'application_store/rails_application'
require_relative 'application_store/store_composite'
require_relative 'application_store/core_ext/hash'


