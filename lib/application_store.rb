require "application_store/version"

module ApplicationStore
  def root
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
    applications
  end
  module_function :root, :applications, :rename
end

require_relative 'application_store/store_composite'
