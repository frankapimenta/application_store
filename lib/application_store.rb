require "application_store/version"

module ApplicationStore
  def applications(name: nil)
    @applications ||= if name
      StoreComposite.new name: name
    else
      StoreComposite.new
    end
  end
  module_function :applications
end

require_relative 'application_store/store_composite'
