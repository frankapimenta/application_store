RSpec.describe ApplicationStore::Config do
  let(:full_path_to_configuration_file) { File.join(ApplicationStore::root_path, configuration_file_path) }
  let(:configuration_file_path)         { "lib/configuration.yml" }
  context "initialization" do
    specify "initialized with no error when no configuration file path is given (using default configuration file)" do
      expect { described_class.new }.not_to raise_error
    end
    specify "uses default configuration file when initialized with no file path to configuration file" do
      expect(described_class).to receive(:default_configuration_file_path).and_call_original
      described_class.new
    end
    specify "has configuration_file_path as default configuration file path" do
      expect(described_class.new.instance_variable_get(:@configuration_file_path)).to eq(described_class::default_configuration_file_path)
    end
    specify "raises error if file does not exist (bad path)" do
      expect { described_class.new 'file_does_not_exist_due_to_bad_path' }.to raise_error StandardError, "file does not exist or path given is wrong"
    end
    specify "initialized with configuration_file_path" do
      expect { described_class.new(full_path_to_configuration_file) }.not_to raise_error
    end
    specify "stores full path to configuration file in @configuration_file_path" do
      expect(described_class.new(full_path_to_configuration_file).instance_variable_get(:@configuration_file_path)).to eq(full_path_to_configuration_file)
    end
  end
  context "class methods" do
    context ".default_configuration_file_path" do
      specify { expect(described_class).to respond_to(:default_configuration_file_path).with(0).arguments }
      specify { expect(described_class::default_configuration_file_path).to eq File.join(ApplicationStore::root_path, "/lib/configuration.yml") }
    end
  end
end
