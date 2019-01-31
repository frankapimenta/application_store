require "application_store/version"

module ApplicationStore
  class Error < StandardError; end
  # Your code goes here...
end


require_relative 'application_store/refinements/hash'
require_relative 'application_store/store/general_store'
require_relative 'application_store/store/hash_store'
require_relative 'application_store/store/global_store'
require_relative 'application_store/store'
