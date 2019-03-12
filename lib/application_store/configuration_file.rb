module ApplicationStore
  class ConfigurationFile
    ALLOWED_EXTENSIONS = [:yaml, :yml]
    attr_reader :location_path, :file_name

    def initialize(location_path: ApplicationStore::Config.config_path, file_name: )
      @location_path, @file_name = location_path, file_name
    end

    def exists?
      File.exists?(file_path)
    end

    def file_path
      File.join(@location_path, @file_name)
    end
  end
end
