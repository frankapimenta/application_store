# TODO: check #count on #store for empty store
require "application_store/version"
require "application_store/modules/parenthood"

module ApplicationStore

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
      content.each_pair do |key, value|
        _store = store.create name: key
        value.each_pair do |key, value|
          _store.set key, value
        end
      end
    end
  end

  module_function :root_path, :store, :rename, :config, :content, :reset!, :run!
end

require_relative 'application_store/config'
require_relative 'application_store/store_composite'
require_relative 'application_store/core_ext/hash'


