RSpec.describe ApplicationStore::Config do
  let(:path_to_config) { File.join(File.expand_path(File.dirname(__FILE__)), '../config') }
  context "on initialization" do
    before do
      allow(described_class).to receive(:config_path).and_return path_to_config
      allow(ENV).to receive(:[]).with('APPLICATION_STORE_ENVIRONMENT').and_return 'development'
    end
    context "on raising error conditions" do
      specify "raises error when no file name given" do
        expect { described_class.new }.to raise_error ArgumentError, "missing keyword: file_name"
      end
      specify "raises error if given file path does not exist (bad path)" do
        expect { described_class.new file_name: 'confiuration.yml' }.to raise_error StandardError, "configuration file does not exist or path given is wrong"
      end
      specify "does not raise error if file exists" do
        expect { described_class.new(file_name: 'application_store.yml') }.not_to raise_error
      end
    end
    specify "calls #configuration_file.exists?" do
      expect_any_instance_of(ApplicationStore::ConfigurationFile).to receive(:exists?).and_call_original
      described_class.new file_name: 'application_store.yml'
    end
    context "on setting @environment" do
      specify "sets environment from APP ENV when environment is not given" do
        expect(described_class).to receive(:environment).and_call_original
        expect(described_class.new(file_name: 'application_store.yml').instance_variable_get(:@environment)).to eq :development
      end
      specify "sets given environment" do
        instance = described_class.new environment: :production, file_name: 'application_store.yml'
        expect(instance.instance_variable_get(:@environment)).to eq :production
      end
    end
    context "on setting @configuration_file" do
      specify "sets configuration_file instance when file_name is given is given" do
        instance = described_class.new file_name: 'application_store.yml'
        expect(instance.instance_variable_get(:@configuration_file)).to be_instance_of(ApplicationStore::ConfigurationFile)
      end
    end
  end
  context "instance methods" do
    before { allow(described_class).to receive(:config_path).and_return path_to_config }
    context "#configuration_file" do
      subject { described_class.new environment: :development, file_name: 'application_store.yml' }
      specify { expect(subject).to respond_to(:configuration_file).with(0).arguments }
      specify { expect(subject.configuration_file).to eq subject.instance_variable_get(:@configuration_file) }
      specify { expect(subject.configuration_file).to be_instance_of ApplicationStore::ConfigurationFile }
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
    context ".config_path" do
      let(:config_path) { File.join(ApplicationStore::root_path, 'lib/config') }
      specify { expect(described_class).to respond_to(:config_path).with(0).arguments }
      specify "receives root_path" do
        expect(ApplicationStore).to receive(:root_path).and_call_original
        described_class.config_path
      end
      specify { expect(described_class.config_path).to eq config_path }
    end
  end
end
