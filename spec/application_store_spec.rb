RSpec.describe ApplicationStore do
  after { subject.instance_variable_set(:@applications, nil) }
  specify { expect(subject).to be_instance_of Module }
  context "module methods" do
    context "::root_path" do
      specify { expect(described_class).to respond_to(:root_path).with(0).arguments }
      specify { expect(described_class::root_path).to eq File.expand_path(File.join(File.dirname(__FILE__), '../')) }
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
      specify "memoizes" do
        expect(described_class.config).to be described_class.config
      end
    end
    context "#configurations" do
      before { allow(ApplicationStore::Config).to receive(:environment).and_return environment }
      let(:environment)    { :development }
      let(:config)         { double :config }
      specify { expect(described_class).to respond_to(:configurations).with_keywords(:environment) }
      specify "calls ::config" do
        expect(described_class).to receive_message_chain(:config, :configurations)
        described_class.configurations
      end
      specify { expect(described_class.configurations).to be_instance_of ActiveSupport::HashWithIndifferentAccess }
      specify "expects to call ::config with no env given" do
        expect(described_class).to receive_message_chain(:config, :configurations).and_return config
        described_class.configurations
      end
      specify "expects to call ::config with given env" do
        expect(described_class).to receive(:config).with(environment: :staging).and_return config
        expect(config).to receive(:configurations).with(environment: :staging)
        described_class.configurations(environment: :staging)
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
  end
end
