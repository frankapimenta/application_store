require "application_store/version"

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

  def configurations environment: Config.environment
    configurations = config(environment: environment).configurations(for_env: environment)

    yield configurations if block_given?

    configurations
  end

  module_function :root_path, :applications, :rename, :config, :configurations
end

require_relative 'application_store/config'
require_relative 'application_store/store_composite'
require_relative 'application_store/core_ext/hash'


