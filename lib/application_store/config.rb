require_relative "configuration_file"

module ApplicationStore
  class Config

    attr_reader :configuration_file

    def initialize environment: Config.environment,  file_name: 'application_store.yml'
      @environment        = environment
      @configuration_file = ConfigurationFile.new file_name: file_name

      raise StandardError.new "configuration file does not exist or path given is wrong" unless @configuration_file.exists?
    end

    def configurations for_env: Config.environment
      configuration_file.content[configuration_file.file_basename][for_env]
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

      def config_path
        File.join(ApplicationStore::root_path, 'lib/config')
      end
    end

  end
end

