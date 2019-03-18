RSpec.describe ApplicationStore do
  before { allow(ENV).to receive(:[]).with('APPLICATION_STORE_ROOT_PATH').and_return root_path }
  after { subject.instance_variable_set(:@applications, nil) }
  let(:root_path) { "/" }

  specify { expect(subject).to be_instance_of Module }
  context "module methods" do
    context "::root_path" do
      let(:root_path) { "lib/config/application_store/" }
      specify { expect(described_class).to respond_to(:root_path).with(0).arguments }
      context "given path via Rails.root" do
        specify "expects to call Rails.root" do
          rails = class_double('Rails').as_stubbed_const(:transfer_nested_constants => true)
          expect(Object).to receive(:const_defined?).with(:Rails).and_return true
          expect(rails).to receive(:root).and_return root_path
          expect(described_class.root_path).to eq root_path
        end
      end
      context "given path via ENV variable" do
        specify "calls ENV" do
          expect(ENV).to receive(:[]).with('APPLICATION_STORE_ROOT_PATH')
          described_class.root_path
        end
        specify "returns ENV instance of default config path" do
          allow(ENV).to receive(:[]).and_return root_path
          expect(described_class.root_path).to eq root_path
        end
      end
      context "raises if not in rails and env var not defined" do
        before { allow(ENV).to receive(:[]).with('APPLICATION_STORE_ROOT_PATH') }
        specify { expect { described_class.root_path }.to raise_error StandardError, "you must defined env var APPLICATION_STORE_ROOT_PATH when not in a Rails app" }
      end
    end
    context "::applications" do
      let(:applications) { described_class.applications }
      specify { expect(described_class).to respond_to(:applications) }
      specify { expect(described_class.applications).to be_instance_of ApplicationStore::StoreComposite }
      specify "memoizes" do
        _applications = described_class.applications
        expect(_applications).to eq applications
      end
      context "#::applications can receive name for naming store" do
        specify { expect { described_class.applications(name: 'contacts_client_token_store') }.not_to raise_error }
      end
      context "#::applications storage default name is :app" do
        specify { expect(described_class.applications.name).to eq :__default__store__ }
      end
      context "store name is prefixed with __ and suffixed with __store__" do
        specify { expect(described_class.applications(name: 'contacts_client').name).to eq :__contacts_client__store__ }
      end
    end
    context "can add and remove applications auth data" do
      let(:application0) { ApplicationStore::Store.new name: 'application0' }
      let(:application1) { ApplicationStore::Store.new name: 'application1' }
      let(:application2) { ApplicationStore::Store.new name: 'application2' }
      specify "add applications to applications store" do
        expect(subject.applications).to be_empty
        subject.applications.add application0
        subject.applications.add application1
        subject.applications.add application2
        expect(subject.applications).not_to be_empty
        expect(subject.applications.count).to eq 3
        expect(subject.applications.to_hash).to eq({__default__store__: {application0: {name: :application0}, application1: {name: :application1}, application2: {name: :application2}}})
      end
      specify "removes applications" do
        expect(subject.applications).to be_empty
        subject.applications.add application0
        subject.applications.add application1
        expect(subject.applications)
      end
    end
    context "#create" do
      specify "can create app directly" do
        subject.applications.create name: 'app'
      end
      specify "returns created app" do
        app = subject.applications.create name: 'app'
        expect(app).to be_instance_of ApplicationStore::Store
        expect(app.name).to eq :app
      end
      specify "access app after creating" do
        subject.applications.create name: 'app'
        expect(subject.applications.get :app).to be_instance_of ApplicationStore::Store
        expect(subject.applications.get(:app).name).to eq :app
      end
    end
    context "#rename" do
      specify { expect(subject).to respond_to(:rename).with(1).argument }
      specify "renames store" do
        expect(subject.applications.instance_variable_get(:@store).store.keys).to include(:__default__store__)
        expect(subject.applications.name).to eq :__default__store__
        subject.rename 'new-store'
        expect(subject.applications.name).to eq 'new-store'.to_sym
        expect(subject.applications.instance_variable_get(:@store).store.keys).not_to include(:__default__store__)
      end
      specify "returns application renamed with outer scope" do
        expect(subject.rename('another-new-store')).to eq({"another-new-store" => subject.applications.store})
      end
    end
    context "#config" do
      before do
        allow(ApplicationStore::Config).to receive(:environment).and_return environment
        allow(ApplicationStore::Config).to receive(:config_path).and_return path_to_config
      end
      subject { described_class.config environment: :development, file_name: configuration_file_name }

      let(:environment)    { :development }
      let(:path_to_config) { File.join(File.expand_path(File.dirname(__FILE__)), 'config/') }
      let(:configuration_file_name) { 'application_store.yml' }

      specify { expect(described_class).to respond_to(:config).with_keywords(:environment, :file_name) }
      specify { expect(described_class.config).to be_instance_of ApplicationStore::Config }
    end
    context "#configurations" do
      before do
        allow(ApplicationStore::Config).to receive(:environment).and_return environment
        allow(ApplicationStore::Config).to receive(:config_path).and_return 'spec/config'
      end
      let(:environment)       { :development }
      let(:config)            { double :config }
      let(:file_name)         { 'another_application_store_config_file.yml' }
      let(:default_file_name) { 'application_store.yml' }
      specify { expect(described_class).to respond_to(:configurations).with_keywords(:environment, :file_name) }
      specify "calls ::config" do
        expect(described_class).to receive_message_chain(:config, :configurations)
        described_class.configurations
      end
      specify { expect(described_class.configurations).to be_instance_of ActiveSupport::HashWithIndifferentAccess }
      specify "expects to call ::config with no env given" do
        expect(described_class).to receive_message_chain(:config, :configurations).and_return config
        described_class.configurations
      end
      specify "expects to call ::config with default env and default file_name" do
        expect(described_class).to receive(:config).with(environment: :development, file_name: default_file_name).and_return config
        expect(config).to receive(:configurations).with(environment: :development)
        described_class.configurations
      end
      specify "expects to call ::config with given env and default file name" do
        expect(described_class).to receive(:config).with(environment: :staging, file_name: default_file_name).and_return config
        expect(config).to receive(:configurations).with(environment: :staging)
        described_class.configurations(environment: :staging)
      end
      specify "expects to call :config with given file_name and default env" do
        expect(described_class).to receive(:config).with(environment: :development, file_name: file_name).and_return config
        expect(config).to receive(:configurations).with(environment: :development)
        described_class.configurations(file_name: file_name)
      end
      specify "yiels if block given" do
        expect { |b| described_class.configurations(&b) }.to yield_control
        described_class.configurations
      end
      specify "returns configurations for current env" do
        expect(described_class.configurations.finance_manager.configurations.email.smtp.host).to match(/development/)
      end
      specify "returns configurations for staging env" do
        expect(described_class.configurations(environment: :staging).finance_manager.configurations.email.smtp.host).to match(/staging/)
      end
    end
    context "#run!" do
      before do
        allow(ApplicationStore::Config).to receive(:environment).and_return environment
        allow(ApplicationStore::Config).to receive(:config_path).and_return path_to_config
      end
      # remove memoization of #config (not to leak to other tests)
      after { described_class.instance_variable_set(:@config, nil) }

      let(:path_to_config) { File.join(File.expand_path(File.dirname(__FILE__)), 'config/') }
      let(:applications)    { double :applications }
      let(:configurations)  { double :configurations }
      let(:environment)     { :development }
      let(:store)           { double :store }
      let(:default_file_name) { 'application_store.yml' }
      specify { expect(described_class).to respond_to(:run!).with_keywords(:environment, :file_name) }
      specify "calls #configurations with default environment and file_name" do
        expect(described_class).to receive(:configurations).with(environment: environment, file_name: default_file_name).and_yield configurations
        expect(configurations).to receive(:each_pair)
        described_class.run!
      end
      specify "calls #configurations with given environment and file_name" do
        expect(described_class).to receive(:configurations).with(environment: :staging, file_name: 'other_application_store.yml').and_yield configurations
        expect(configurations).to receive(:each_pair)
        described_class.run! environment: :staging, file_name: 'other_application_store.yml'
      end
      specify "calls “#applications and #add" do
        expect(described_class).to receive(:applications).and_return(applications)
        expect(applications).to receive(:create).with(name: "finance_manager").and_return store
        expect(store).to receive(:set).with("configurations", an_instance_of(ActiveSupport::HashWithIndifferentAccess)).and_return store
        expect(store).to receive(:set).with("contacts_client", an_instance_of(ActiveSupport::HashWithIndifferentAccess)).and_return store
        described_class.run!
      end
      specify "stores configurations of applications for default variables" do
        expect(described_class.applications.count).to eq 0
        described_class.run!
        expect(described_class.applications.count).to eq 1
      end
      specify "stores configurations of applications for given variables" do
        expect(described_class.applications.count).to eq 0
        described_class.run! environment: :staging, file_name: 'other_application_store.yml'
        expect(described_class.applications.count).to eq 1
        expect(described_class.applications.finance_manager.configurations.email.smtp.host).to eq 'staging.smtp.y.ch'
      end
    end
  end
end
