module ApplicationStore
  class Config

    def initialize configuration_file_path = ApplicationStore::default_configuration_file_path
      @configuration_file_path = configuration_file_path

      raise StandardError.new "file does not exist or path given is wrong" unless File.exists?(@configuration_file_path)
    end

  end
end
