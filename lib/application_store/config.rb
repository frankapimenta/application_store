module ApplicationStore
  class Config

    def initialize environment: Config.environment,  configuration_file_path: Config.default_configuration_file_path
      self.class.instance_variable_set(:@environment, environment)
      self.class.instance_variable_set(:@configuration_file_path, configuration_file_path)

      raise StandardError.new "configuration file does not exist or path given is wrong" unless File.exists?(self.class.configuration_file_path)
      # TODO: load configuration yaml here
    end

    class << self
      def environment
        begin
          Rails.env
        rescue NameError
          _environment = ENV['APPLICATION_STORE_ENVIRONMENT']
          raise StandardError.new("environment not defined as expected") if _environment.nil?
          _environment
        end.to_sym
      end
      def configuration_file_path
        @configuration_file_path || default_configuration_file_path
      end
      # TODO ::configuration_file_path
      def config_path
        File.join(ApplicationStore::root_path, 'lib/config')
      end

      def default_configuration_file_path
        File.join(config_path, 'configuration.yml')
      end
    end

  end
end
