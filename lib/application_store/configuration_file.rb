class ConfigurationFile
  attr_reader :location_path, :file_name

  def initialize(location_path: ApplicationStore::Config.config_path, file_name: )
    @location_path, @file_name = location_path, file_name
  end

  def exists?
    File.exists?(configuration_file_path)
  end

  def configuration_file_path
    File.join(@location_path, @file_name)
  end

end
