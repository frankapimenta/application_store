require_relative "configuration_file"

module ApplicationStore
  class Config

    def initialize environment: Config.environment,  file_name:
      @environment = environment
      @file_name   = file_name
      # TODO: REFACTOR
      # class extraction
      #   => extract #configuration_file_* methods to ConfigurationFile
      #   class ConfigurationFile
      #     def initialize location:, file_name:
      #       @location, @file_name = location, file_name
      #     end
      #   end

      raise StandardError.new "configuration file does not exist or path given is wrong" unless configuration_file_exists?
      # TODO: load configuration yaml here
    end

    def configuration_file_exists?
      File.exists?(configuration_file_path)
    end

    def configuration_file_path
      File.join(self.class.config_path, @file_name)
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
      # TODO ::configuration_file_path
      def config_path
        File.join(ApplicationStore::root_path, 'lib/config')
      end
    end

  end
end
