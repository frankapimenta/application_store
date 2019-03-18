# TODO: check #count on #applications for empty store
require "application_store/version"
require "application_store/modules/parenthood"

module ApplicationStore

  def root_path
    return Rails.root if Object.const_defined? :Rails

    raise StandardError.new "you must defined env var APPLICATION_STORE_ROOT_PATH when not in a Rails app" unless ENV['APPLICATION_STORE_ROOT_PATH']

    ENV['APPLICATION_STORE_ROOT_PATH']
  end

  def applications(name: nil)
    @applications ||= if name
      StoreComposite.new name: name
    else
      StoreComposite.new
    end
  end

  def rename name
    applications.rename name
    { "#{name}" => applications.store }
  end

  def config environment: Config.environment, file_name: 'application_store.yml'
    Config.new environment: environment, file_name: file_name
  end

  def configurations environment: Config.environment, file_name: 'application_store.yml'
    configurations = config(environment: environment, file_name: file_name).configurations(environment: environment)

    yield configurations if block_given?

    configurations
  end

  def run! environment: Config.environment, file_name: 'application_store.yml'
    configurations(environment: environment, file_name: file_name) do |configurations|
      configurations.each_pair do |key, value|
        store = applications.create name: key
        value.each_pair do |key, value|
          store.set key, value
        end
      end
    end
  end

  module_function :root_path, :applications, :rename, :config, :configurations, :run!
end

require_relative 'application_store/config'
require_relative 'application_store/store_composite'
require_relative 'application_store/core_ext/hash'


