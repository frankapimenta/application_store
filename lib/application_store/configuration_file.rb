require 'erb'
require 'active_support/core_ext/hash'
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

    def file_extension
      File.extname file_path
    end

    def file_type
      file_extension[1..-1].to_sym
    end

    def file_basename
      File.basename @file_name, file_extension
    end

    def content
      @content ||= load_file.with_indifferent_access
    end

    private def is_yml?
      ALLOWED_EXTENSIONS.include? file_type
    end

    private def load_file
      YAML.load(ERB.new(File.read(file_path)).result)
    end

  end
end
