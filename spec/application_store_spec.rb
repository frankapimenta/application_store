RSpec.describe ApplicationStore do
  after { subject.instance_variable_set(:@applications, nil) }
  specify { expect(subject).to be_instance_of Module }
  context "module methods" do
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
        specify { expect(described_class.applications.name).to eq :__api_token_auth__default__store__ }
      end
      context "store name is prefixed with __api_token_auth__ and suffixed with __store__" do
        specify { expect(described_class.applications(name: 'contacts_client').name).to eq :__api_token_auth__contacts_client__store__ }
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
      end
    end
  end
end
