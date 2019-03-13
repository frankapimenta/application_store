RSpec.describe ApplicationStore::Config do
  let(:path_to_config) { File.join(File.expand_path(File.dirname(__FILE__)), '../config') }
  let(:configuration_file_name) { 'application_store.yml' }
  context "on initialization" do
    before do
      allow(described_class).to receive(:config_path).and_return path_to_config
      allow(ENV).to receive(:[]).with('APPLICATION_STORE_ENVIRONMENT').and_return 'development'
    end
    context "on raising error conditions" do
      specify "raises error if given file path does not exist (bad path)" do
        expect { described_class.new file_name: 'confiuration.yml' }.to raise_error StandardError, "configuration file does not exist or path given is wrong"
      end
      specify "does not raise error if file exists" do
        expect { described_class.new(file_name: configuration_file_name) }.not_to raise_error
      end
      specify "does not raise error for default file name if exists" do
        expect { subject }.not_to raise_error
      end
      specify { expect(subject.configuration_file.file_name).to eq configuration_file_name }
    end
    specify "calls #configuration_file.exists?" do
      expect_any_instance_of(ApplicationStore::ConfigurationFile).to receive(:exists?).and_call_original
      described_class.new file_name: configuration_file_name
    end
    context "on setting @environment" do
      specify "sets environment from APP ENV when environment is not given" do
        expect(described_class).to receive(:environment).and_call_original
        expect(subject.instance_variable_get(:@environment)).to eq :development
      end
      specify "sets given environment" do
        instance = described_class.new environment: :production, file_name: configuration_file_name
        expect(instance.instance_variable_get(:@environment)).to eq :production
      end
    end
    context "on setting @configuration_file" do
      specify "sets configuration_file instance when file_name is given is given" do
        expect(subject.configuration_file).to be_instance_of(ApplicationStore::ConfigurationFile)
      end
    end
  end
  context "instance methods" do
    before { allow(described_class).to receive(:config_path).and_return path_to_config }
    subject { described_class.new environment: :development, file_name: configuration_file_name }
    context "#environment" do
      specify { expect(subject).to respond_to(:environment).with(0).arguments }
      specify { expect(subject.environment).to eq :development}
    end
    context "#configuration_file" do
      specify { expect(subject).to respond_to(:configuration_file).with(0).arguments }
      specify { expect(subject.configuration_file).to eq subject.instance_variable_get(:@configuration_file) }
      specify { expect(subject.configuration_file).to be_instance_of ApplicationStore::ConfigurationFile }
    end
    context "#configurations" do
      let(:content) { double :content }
      specify { expect(subject).to respond_to(:configurations).with_keywords(:environment) }
      specify "calls #content in configuration_file" do
        expect(subject).to receive(:configuration_file).twice.and_return content
        expect(content).to receive(:content).and_return content
        expect(content).to receive(:file_basename).and_return content
        expect(content).to receive(:[]).with(content).and_return content
        expect(content).to receive(:[]).with(:development).and_return content
        subject.configurations
      end
      context "returns configurations for current env" do
        specify { expect(subject.configurations).to be_instance_of ActiveSupport::HashWithIndifferentAccess }
        specify { expect(subject.configurations).to be subject.configuration_file.content.application_store.development }
      end
      context "for given env :development" do
        specify { expect(subject.configurations(environment: :development).finance_manager.configurations.email.smtp.host).to eq 'development.smtp.x.ch' }
      end
      context "for given env :staging" do
        specify { expect(subject.configurations(environment: :staging).finance_manager.configurations.email.smtp.host).to eq 'staging.smtp.x.ch' }
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
