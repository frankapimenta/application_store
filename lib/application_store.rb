# TODO: check #count on #applications for empty store
require "application_store/version"
require "application_store/modules/parenthood"

module ApplicationStore

  def root_path
    File.dirname __dir__
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
    @config ||= Config.new environment: environment, file_name: file_name
  end

  def configurations environment: Config.environment, file_name: 'application_store.yml'
    configurations = config(environment: environment, file_name: file_name).configurations(environment: environment)

    yield configurations if block_given?

    configurations
  end

  def run! environment: Config.environment
    configurations(environment: environment) do |configurations|
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


