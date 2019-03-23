module ApplicationStore
  class RailsApplication
    attr_reader :rails_application

    def initialize rails_application
      raise StandardError.new "you have to initialize with a Rails application" unless rails_application.is_a? ::Rails::Application
      @rails_application = rails_application
    end

    def method_missing method, *args, &block
      unless method.to_s.include? '='
        if rails_application.config.respond_to?(method)
          rails_application.config.__send__ method, *args, &block
        else
          rails_application.config_for(method)
        end
      else
        rails_application.config.__send__ method, *args, &block
      end
    end
  end
end
