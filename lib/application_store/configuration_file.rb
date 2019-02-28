class ConfigurationFile
  attr_reader :location_path, :file_name

  def initialize(location_path: ApplicationStore::Config.config_path, file_name: )
    @location_path, @file_name = location_path, file_name
  end
end
