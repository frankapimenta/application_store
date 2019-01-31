require "api_token_store/version"

module ApiTokenStore
  class Error < StandardError; end
  # Your code goes here...
end


require_relative 'api_token_store/refinements/hash'
require_relative 'api_token_store/store/general_store'
