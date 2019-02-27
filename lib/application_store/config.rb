module ApplicationStore
  class Config

    def initialize configuration_file_path = Config.default_configuration_file_path
      @configuration_file_path = configuration_file_path

      raise StandardError.new "file does not exist or path given is wrong" unless File.exists?(@configuration_file_path)
      # TODO: load configuration yaml here
    end

    class << self
      def default_configuration_file_path
        File.join(ApplicationStore::root_path, 'lib/configuration.yml')
      end
    end

  end
end
