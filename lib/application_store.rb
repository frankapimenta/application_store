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

  module_function :root_path, :applications, :rename
end

require_relative 'application_store/config'
require_relative 'application_store/store_composite'
require_relative 'application_store/core_ext/hash'
