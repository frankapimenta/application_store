require_relative "configuration_file"

module ApplicationStore
  class Config

    attr_reader :environment, :configuration_file

    def initialize environment: Config.environment,  file_name: 'application_store.yml'
      @environment        = environment
      @configuration_file = ConfigurationFile.new file_name: file_name

      raise StandardError.new "configuration file does not exist or path given is wrong" unless @configuration_file.exists?
    end

    def content environment: self.environment
      # TODO: raise if content has not the environment key (due to bad file)
      configuration_file.content[configuration_file.file_basename][environment]
    end

    class << self
      def environment
        begin
          ENV['APPLICATION_STORE_ENVIRONMENT'] || Rails.env
        rescue NameError
          raise StandardError.new("environment not defined as expected")
        end.to_sym
      end

      def config_path
        ENV['APPLICATION_STORE_CONFIG_PATH'] || File.join(ApplicationStore::root_path, 'config')
      end
    end

  end
end

