RSpec.describe ApplicationStore::Config do
  let(:configuration_file_path)         {  ApplicationStore::Config.default_configuration_file_path }
  let(:full_path_to_configuration_file) { configuration_file_path }
  context "on initialization" do
    before { allow(ENV).to receive(:[]).with('APPLICATION_STORE_ENVIRONMENT').and_return 'development' }
    context "on setting @environment" do
      specify "sets environment from APP ENV when environment is not given" do
        expect(described_class).to receive(:environment).and_return :development
        expect(described_class.new.instance_variable_get(:@environment)).to eq :development
      end
      specify "sets given environment" do
        instance = described_class.new environment: :production
        expect(instance.instance_variable_get(:@environment)).to eq :production
      end
    end
    context "on setting @configuration_file_path" do
      before { allow(File).to receive(:exists?).and_return true }
      specify "sets default configuration file path when configuration_file_path is not given" do
        expect(described_class).to receive(:default_configuration_file_path).twice.and_call_original
        described_class.new
        expect(described_class.instance_variable_get(:@configuration_file_path)).to eq described_class.default_configuration_file_path
      end
      specify "sets configuration_file_path when configuration file path is given" do
        described_class.new configuration_file_path: 'configuration_file_path'
        expect(described_class.instance_variable_get(:@configuration_file_path)).to eq 'configuration_file_path'
        expect(described_class.configuration_file_path).to eq 'configuration_file_path'
      end
    end
    context "on raising error when configuration file does not exist" do
      specify "calls File.exists?" do
        allow(described_class).to receive(:configuration_file_path).and_return 'configuration_file_path'
        expect(File).to receive(:exists?).with('configuration_file_path').and_return true
        described_class.new
      end
      specify "calls Config.configuration_file_path" do
        allow(File).to receive(:exists?).and_return true
        expect(described_class).to receive(:configuration_file_path).and_return 'configuration_file_path'
        described_class.new
      end
      specify "raises error if given file path does not exist (bad path)" do
        expect { described_class.new configuration_file_path: 'file_does_not_exist_due_to_bad_path' }.to raise_error StandardError, "configuration file does not exist or path given is wrong"
      end
      specify "stores given full path to configuration file in @configuration_file_path" do
        expect(described_class.new(configuration_file_path: full_path_to_configuration_file).class.instance_variable_get(:@configuration_file_path)).to eq(full_path_to_configuration_file)
      end
    end
  end
  context "class methods" do
    context ".environment" do
      before do
        allow(rails_constant).to receive(:env).and_raise NameError.new
        allow(ENV).to receive(:[]) # not defined by default
      end
      let(:rails_constant) { class_double('Rails'). as_stubbed_const }
      specify { expect(described_class).to respond_to(:environment).with(0).arguments }
      specify "raises if env not defined" do
        expect { described_class.environment }.to raise_error StandardError, "environment not defined as expected"
      end
      specify "retrieve environment from Rails.env (is default)" do
        expect(rails_constant).to receive(:env).and_return 'development'
        expect(described_class.environment).to eq :development
      end
      specify "retrieve environment from RACK_ENV (when not in Rails)" do
        expect(ENV).to receive(:[]).with('APPLICATION_STORE_ENVIRONMENT').and_return 'development'
        expect(described_class.environment).to eq :development
      end
    end
    context ".configuration_file_path" do
      before { described_class.instance_variable_set(:@configuration_file_path, nil) }
      specify { expect(described_class).to respond_to(:configuration_file_path).with(0).arguments }
      specify "is default configuration file path if not set on init" do
        expect(described_class).to receive(:default_configuration_file_path).and_call_original
        described_class.configuration_file_path
      end
      specify "is @configuration_file_path if set" do
        described_class.instance_variable_set(:@configuration_file_path, "configuration_file_path")
        expect(described_class.configuration_file_path).to eq "configuration_file_path"
      end
    end
    context ".config_path" do
      let(:config_path) { File.join(ApplicationStore::root_path, 'lib/config') }
      specify { expect(described_class).to respond_to(:config_path).with(0).arguments }
      specify "receives root_path" do
        expect(ApplicationStore).to receive(:root_path).and_call_original
        described_class.config_path
      end
      specify { expect(described_class.config_path).to eq config_path }
    end
    context ".default_configuration_file_path" do
      specify { expect(described_class).to respond_to(:default_configuration_file_path).with(0).arguments }
      specify "calls .config_path" do
        expect(described_class).to receive(:config_path).and_call_original
        described_class.default_configuration_file_path
      end
      specify { expect(described_class::default_configuration_file_path).to eq File.join(described_class::config_path, "configuration.yml") }
    end
  end
end
