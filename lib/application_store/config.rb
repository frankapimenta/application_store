module ApplicationStore
  class Config

    def initialize configuration_file_path = Config.default_configuration_file_path
      # TODO: enable env via arguments
      @configuration_file_path = configuration_file_path

      raise StandardError.new "file does not exist or path given is wrong" unless File.exists?(@configuration_file_path)
      # TODO: load configuration yaml here
    end

    class << self
      def environment
        begin
          @environment || Rails.env
        rescue NameError
          _environment = ENV['APPLICATION_STORE_ENVIRONMENT']
          raise StandardError.new("environment not defined as expected") if _environment.nil?
          _environment
        end.to_sym
      end
      def config_path
        File.join(ApplicationStore::root_path, 'lib/config')
      end

      def default_configuration_file_path
        File.join(config_path, 'configuration.yml')
      end
    end

  end
end
