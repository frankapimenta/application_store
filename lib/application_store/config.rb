require_relative "configuration_file"

module ApplicationStore
  class Config

    def initialize environment: Config.environment,  file_name:
      @environment        = environment
      @configuration_file = ConfigurationFile.new file_name: file_name

      raise StandardError.new "configuration file does not exist or path given is wrong" unless @configuration_file.exists?
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

      def config_path
        File.join(ApplicationStore::root_path, 'lib/config')
      end
    end

  end
end
