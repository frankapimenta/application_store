require "application_store/version"

module ApplicationStore

  def root_path
    File.dirname __dir__
  end

  def default_configuration_file_path
    File.join(ApplicationStore::root_path, 'lib/configuration.yml')
  end
  module_function :root_path, :default_configuration_file_path

  def applications(name: nil)
    @applications ||= if name
      StoreComposite.new name: name
    else
      StoreComposite.new
    end
  end

  def rename name
    applications.rename name
    applications
  end

  module_function :applications, :rename
end

require_relative 'application_store/store_composite'
