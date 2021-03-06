RSpec.describe ApplicationStore do
  before do
    allow(ENV).to receive(:[]).with('APPLICATION_STORE_ROOT_PATH').and_return root_path
    allow(ENV).to receive(:[]).with('APPLICATION_STORE_PORT').and_return 300
  end
  after { subject.instance_variable_set(:@store, nil) }
  let(:root_path) { "/" }

  specify { expect(subject).to be_instance_of Module }
  context "module methods" do
    context "::rails_app" do
      specify "forwards to ::rails_application" do
        expect(described_class).to receive(:rails_application)
        described_class::rails_app
      end
    end
    context "::rails_application" do
      let(:rails_constant) { class_double('Rails').as_stubbed_const(:transfer_nested_constants => true) }
      let!(:rails_applicationlication_constant)  { class_double('Rails::Application').as_stubbed_const(:transfer_nested_constants => true) }
      specify { expect(described_class).to respond_to(:rails_application).with(0).arguments }
      specify "raises if Rails is not defined" do
        expect(Object).to receive(:const_defined?).with(:Rails).and_return false
        expect { described_class.rails_application }.to raise_error StandardError, "you are not within a Rails application"
      end
      specify "returns rails application" do
        application = double :application, is_a?: true
        expect(rails_constant).to receive(:application).and_return application
        allow(Object).to receive(:const_defined?).and_return true
        expect(described_class.rails_application).to be_instance_of ApplicationStore::RailsApplication
      end
    end
    context "::root_path" do
      let(:root_path) { "lib/config/application_store/" }
      specify { expect(described_class).to respond_to(:root_path).with(0).arguments }
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
      context "given path via Rails.root" do
        before { allow(ENV).to receive(:[]).with('APPLICATION_STORE_ROOT_PATH') }
        specify "expects to call Rails.root" do
          rails = class_double('Rails').as_stubbed_const(:transfer_nested_constants => true)
          expect(Object).to receive(:const_defined?).with(:Rails).and_return true
          expect(rails).to receive(:root).and_return root_path
          expect(described_class.root_path).to eq root_path
        end
      end
      context "raises if not in rails and env var not defined" do
        before { allow(ENV).to receive(:[]).with('APPLICATION_STORE_ROOT_PATH') }
        specify { expect { described_class.root_path }.to raise_error StandardError, "you must defined env var APPLICATION_STORE_ROOT_PATH when not in a Rails app" }
      end
    end
    context "::store" do
      let(:store) { described_class.store }
      specify { expect(described_class).to respond_to(:store).with(0).arguments }
      specify { expect(described_class.store).to be_instance_of ApplicationStore::StoreComposite }
      specify "memoizes" do
        _store = described_class.store
        expect(_store).to eq store
      end
      context "#::store storage default name is :__default__store__" do
        specify { expect(described_class.store.name).to eq :__default__store__ }
      end
    end
    context "can add and remove store auth data" do
      let(:application0) { ApplicationStore::Store.new name: 'application0' }
      let(:application1) { ApplicationStore::Store.new name: 'application1' }
      let(:application2) { ApplicationStore::Store.new name: 'application2' }
      specify "add store to store store" do
        expect(subject.store).to be_empty
        subject.store.add application0
        subject.store.add application1
        subject.store.add application2
        expect(subject.store).not_to be_empty
        expect(subject.store.count).to eq 3
        expect(subject.store.to_hash).to eq({__default__store__: {application0: {name: :application0}, application1: {name: :application1}, application2: {name: :application2}}})
      end
      specify "removes store" do
        expect(subject.store).to be_empty
        subject.store.add application0
        subject.store.add application1
        expect(subject.store)
      end
    end
    context "#create" do
      specify "can create app directly" do
        subject.store.create name: 'app'
      end
      specify "returns created app" do
        app = subject.store.create name: 'app'
        expect(app).to be_instance_of ApplicationStore::Store
        expect(app.name).to eq :app
      end
      specify "access app after creating" do
        subject.store.create name: 'app'
        expect(subject.store.get :app).to be_instance_of ApplicationStore::Store
        expect(subject.store.get(:app).name).to eq :app
      end
    end
    context "#rename" do
      specify { expect(subject).to respond_to(:rename).with(1).argument }
      specify "renames store" do
        expect(subject.store.instance_variable_get(:@store).store.keys).to include(:__default__store__)
        expect(subject.store.name).to eq :__default__store__
        subject.rename 'new-store'
        expect(subject.store.name).to eq 'new-store'.to_sym
        expect(subject.store.instance_variable_get(:@store).store.keys).not_to include(:__default__store__)
      end
      specify "returns application renamed with outer scope" do
        expect(subject.rename('another-new-store')).to eq({"another-new-store" => subject.store.store})
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
    context "#content" do
      before do
        allow(ApplicationStore::Config).to receive(:environment).and_return environment
        allow(ApplicationStore::Config).to receive(:config_path).and_return 'spec/config'
      end
      let(:environment)       { :development }
      let(:config)            { double :config }
      let(:file_name)         { 'another_application_store_config_file.yml' }
      let(:default_file_name) { 'application_store.yml' }
      specify { expect(described_class).to respond_to(:content).with_keywords(:environment, :file_name) }
      specify "calls ::config" do
        expect(described_class).to receive_message_chain(:config, :content)
        described_class.content
      end
      specify { expect(described_class.content).to be_instance_of ActiveSupport::HashWithIndifferentAccess }
      specify "expects to call ::config with no env given" do
        expect(described_class).to receive_message_chain(:config, :content).and_return config
        described_class.content
      end
      specify "expects to call ::config with default env and default file_name" do
        expect(described_class).to receive(:config).with(environment: :development, file_name: default_file_name).and_return config
        expect(config).to receive(:content).with(environment: :development)
        described_class.content
      end
      specify "expects to call ::config with given env and default file name" do
        expect(described_class).to receive(:config).with(environment: :staging, file_name: default_file_name).and_return config
        expect(config).to receive(:content).with(environment: :staging)
        described_class.content(environment: :staging)
      end
      specify "expects to call :config with given file_name and default env" do
        expect(described_class).to receive(:config).with(environment: :development, file_name: file_name).and_return config
        expect(config).to receive(:content).with(environment: :development)
        described_class.content(file_name: file_name)
      end
      specify "yiels if block given" do
        expect { |b| described_class.content(&b) }.to yield_control
        described_class.content
      end
      specify "returns content for current env" do
        expect(described_class.content.finance_manager.configurations.email.smtp.host).to match(/development/)
      end
      specify "returns content for staging env" do
        expect(described_class.content(environment: :staging).finance_manager.configurations.email.smtp.host).to match(/staging/)
      end
    end
    context "#reset!" do
      specify { expect(described_class).to respond_to(:reset!).with(0).arguments }
      specify "clears @store to enable gem to create a new store composite for #store" do
        expect(described_class.instance_variable_get(:@store)).to be_falsey

        described_class.store

        expect(described_class.instance_variable_get(:@store)).not_to be_falsey

        described_class.reset!

        expect(described_class.instance_variable_get(:@store)).to be_falsey
      end
    end
    context "#run!" do
      specify { expect(described_class).to respond_to(:run!).with_keywords(:environment, :file_name) }
      # application_store:
      #   development:
      #     finance_manager:
      #       name: "at least one key under main key"
      before do
        allow(ApplicationStore::Config).to receive(:environment).and_return environment
        allow(ApplicationStore::Config).to receive(:config_path).and_return path_to_config
      end
      # remove memoization of #config (not to leak to other tests)
      after { described_class.instance_variable_set(:@config, nil) }

      let(:path_to_config) { File.join(File.expand_path(File.dirname(__FILE__)), 'config/') }
      let(:content)         { double :content }
      let(:environment)     { :development }
      let(:store)           { double :store }
      let(:default_file_name) { 'application_store.yml' }
      specify "calls #content with default environment and file_name" do
        expect(described_class).to receive(:content).with(environment: environment, file_name: default_file_name)
        described_class.run!
      end
      specify "calls #content with given environment and file_name" do
        expect(described_class).to receive(:content).with(environment: :staging, file_name: 'other_application_store.yml').and_yield content
        expect(described_class).to receive(:store).and_return store
        expect(described_class).to receive(:nested_store).with(store, content)
        described_class.run! environment: :staging, file_name: 'other_application_store.yml'
      end
      specify "stores content of store for default variables" do
        expect(described_class.store.count).to eq 0
        described_class.run!
        expect(described_class.store.count).to eq 2
      end
      specify "stores content of store for given variables" do
        expect(described_class.store.count).to eq 0
        described_class.run! environment: :staging, file_name: 'other_application_store.yml'
        expect(described_class.store.count).to eq 1
        expect(described_class.store.finance_manager.configurations.email.smtp.host).to eq 'staging.smtp.y.ch'
      end
    end
  end
end
