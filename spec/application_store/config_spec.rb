RSpec.describe ApplicationStore::Config do
  context "on initialization" do
    before { allow(ENV).to receive(:[]).with('APPLICATION_STORE_ENVIRONMENT').and_return 'development' }
    context "on setting @environment" do
      specify "sets environment from APP ENV when environment is not given" do
        expect(described_class).to receive(:environment).and_return :development
        expect(described_class.new(file_name: 'configuration.yml').instance_variable_get(:@environment)).to eq :development
      end
      specify "sets given environment" do
        instance = described_class.new environment: :production, file_name: 'configuration.yml'
        expect(instance.instance_variable_get(:@environment)).to eq :production
      end
    end
    context "on setting @file_name" do
      before { allow(File).to receive(:exists?).and_return true }
      specify "raises error if no file name" do
        expect { described_class.new }.to raise_error ArgumentError, "missing keyword: file_name"
      end
      specify "sets file_name when file_name is given is given" do
        instance = described_class.new file_name: 'file_name'
        expect(instance.instance_variable_get(:@file_name)).to eq 'file_name'
      end
    end
    context "on raising error when configuration file does not exist" do
      specify "calls #configuration_file_exists?" do
        expect_any_instance_of(described_class).to receive(:configuration_file_exists?).and_return true
        described_class.new file_name: 'configuration.yml'
      end
      specify "raises error if given file path does not exist (bad path)" do
        expect { described_class.new file_name: 'confiuration.yml' }.to raise_error StandardError, "configuration file does not exist or path given is wrong"
      end
      specify "does not raise error if file exists" do
        expect { described_class.new(file_name: 'configuration.yml') }.not_to raise_error
      end
    end
  end
  context "instance methods" do
    subject { described_class.new environment: :development, file_name: 'configuration.yml' }
    context "#configuration_file_exists?" do
      specify { expect(subject).to respond_to(:configuration_file_exists?).with(0).arguments }
      context "expectations calls" do
        specify "calls #configuration_file_path" do
          expect(subject).to receive(:configuration_file_path).and_call_original
          subject.configuration_file_exists?
        end
      end
      specify "does not exist (configuration file)" do
        _subject = described_class.new(environment: :development, file_name: 'configuration.yml')
        # we have to manipulate the object in order to avoid raising error on instantiation due to file not existing
        _subject.instance_variable_set(:@file_name, 'confiuration.yml')

        expect(_subject.configuration_file_exists?).to eq false
      end
      specify { expect(subject.configuration_file_exists?).to eq true }
    end
    context "#configuration_file_path" do
      subject { described_class.new environment: :development, file_name: 'configuration.yml' }
      let(:config_path)             { File.join(ApplicationStore::root_path, 'lib/config') }
      let(:file_name)               { subject.instance_variable_get(:@file_name) }
      let(:configuration_file_path) { "#{config_path}/#{file_name}" }
      specify { expect(subject).to respond_to(:configuration_file_path).with(0).arguments }
      context "expectations calls" do
        before { allow(described_class).to receive(:config_path).and_return(config_path) }
        specify "calls File.join" do
          expect(File).to receive(:join).with(config_path, 'configuration.yml').twice.and_call_original
          subject.configuration_file_path
        end
        specify "calls Config.config_path" do
          expect(described_class).to receive(:config_path).and_call_original
          subject.configuration_file_path
        end
      end
      specify { expect(subject.configuration_file_path).to eq(configuration_file_path) }
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
