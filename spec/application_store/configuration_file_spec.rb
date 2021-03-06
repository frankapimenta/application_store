module ApplicationStore
  RSpec.describe ConfigurationFile do
    before do
      allow(ENV).to receive(:[]).with('APPLICATION_STORE_CONFIG_PATH')
      allow(ENV).to receive(:[]).with('APPLICATION_STORE_ROOT_PATH').and_return root_path
      allow(ENV).to receive(:[]).with('APPLICATION_STORE_PORT').and_return 300
    end

    subject { described_class.new(location_path: location_path, file_name: file_name) }

    let(:config_class)  { ApplicationStore::Config }
    let(:location_path) { config_class.config_path }
    let(:file_name)     { 'application_store.yml' }
    let(:file_path)     { "#{location_path}/#{file_name}" }
    let(:root_path)     { '/' }

    context "CONSTANTS" do
      specify { expect(described_class::ALLOWED_EXTENSIONS).to eq [:yaml, :yml] }
    end
    context "on initialization" do
      specify "raises error if file is not an yaml file" do
        expect { described_class.new(file_name: 'application_store.txt') }.to raise_error StandardError, 'configuration file must be a yaml file'
      end
      specify "holds location_path given in @location_path" do
        expect(subject.instance_variable_get(:@location_path)).to eq location_path
      end
      specify "holds file_name given in @file_name" do
        expect(subject.instance_variable_get(:@file_name)).to eq file_name
      end
      specify "raises error if file_name is not given" do
        expect { described_class.new }.to raise_error
      end
      specify "has Config.config_path as default config_path" do
        expect(described_class.new(file_name: file_name).instance_variable_get(:@location_path)).to eq location_path
      end
    end
    context "instance methods" do
      context "#location_path" do
        specify { expect(subject).to respond_to(:location_path).with(0).arguments }
        specify { expect(subject.location_path).to eq location_path }
      end
      context "#file_name" do
        specify { expect(subject).to respond_to(:file_name).with(0).arguments }
        specify { expect(subject.file_name).to eq file_name }
      end
      context "#file_extension" do
        specify { expect(subject).to respond_to(:file_extension).with(0).arguments }
        specify { expect(subject.file_extension).to eq '.yml' }
      end
      context "#file_type" do
        specify { expect(subject).to respond_to(:file_type).with(0).arguments }
        specify "calls #file_extension" do
          expect(subject).to receive(:file_extension).and_call_original
          subject.file_type
        end
        specify { expect(subject.file_type).to eq :yml }
      end
      context "#file_basename" do
        specify { expect(subject).to respond_to(:file_basename).with(0).arguments }
        specify "calls File.basename" do
          expect(subject).to receive(:file_extension).and_call_original
          expect(File).to receive(:basename).with(subject.file_name, '.yml')
          subject.file_basename
        end
        specify { expect(subject.file_basename).to eq file_name.split('.').first }
      end
      context "#content" do
        before { allow(subject).to receive(:file_path).and_return file_path }
        let(:file_path) { File.join(File.expand_path(File.dirname(__FILE__)), '../config/application_store.yml') }
        specify { expect(subject).to respond_to(:content).with(0).arguments }
        specify "calls -load_file" do
          expect(subject).to receive_message_chain(:load_file, :with_indifferent_access)
          subject.content
        end
        specify "can deal with erb env var" do
          expect(subject.content[:application_store][:development][:finance_manager][:contacts_client][:port]).to eq 300
        end
        specify "memoizes loaded content from file" do
          expect(subject).to receive(:load_file).once.and_call_original
          result = subject.content
          expect(subject.content).to be result
        end
        specify { expect(subject.content).to be_instance_of ActiveSupport::HashWithIndifferentAccess }
        specify "is chainable callable" do
          expect(subject.content.application_store.development.finance_manager).to be_instance_of ActiveSupport::HashWithIndifferentAccess
        end
      end
      context "#exists?" do
        specify { expect(subject).to respond_to(:exists?).with(0).arguments }
        context "expectations calls" do
          specify "calls #file_path" do
            expect(subject).to receive(:file_path).and_call_original
            subject.exists?
          end
        end
        specify "does not exist (configuration file)" do
          subject.instance_variable_set(:@file_name, 'confiuration.yml')

          expect(subject.exists?).to eq false
        end
        context "does exist (configuration file)" do
          before { allow(subject).to receive(:file_path).and_return file_path }
          let(:file_path) { File.join(File.expand_path(File.dirname(__FILE__)), '../config/application_store.yml') }
          specify { expect(subject.exists?).to eq true }
        end
      end
      context "#file_path" do
        specify { expect(subject).to respond_to(:file_path).with(0).arguments }
        context "expectations calls" do
          specify "calls File.join" do
            # rspec makes an extra call due to location_path call in the top
            expect(File).to receive(:join).twice.with(location_path, file_name).and_call_original
            subject.file_path
          end
        end
        specify { expect(subject.file_path).to eq(file_path) }
      end
    end
  end
end
