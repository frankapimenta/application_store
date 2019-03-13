require 'yaml'

module ApplicationStore
  class ConfigurationFile
    ALLOWED_EXTENSIONS = [:yaml, :yml]
    attr_reader :location_path, :file_name

    def initialize(location_path: ApplicationStore::Config.config_path, file_name: )
      @location_path, @file_name = location_path, file_name

      raise StandardError, "configuration file must be a yaml file" unless is_yml?
    end

    def exists?
      File.exists?(file_path)
    end

    def file_path
      File.join(@location_path, @file_name)
    end

    def file_type
      File.extname(file_path)[1..-1].to_sym
    end

    def content
      @content ||= load_file
    end

    private def is_yml?
      ALLOWED_EXTENSIONS.include? file_type
    end

    private def load_file
      YAML::load_file file_path
    end

  end
end
