module ApplicationStore
  RSpec.describe StoreComposite do
    let(:store) { subject.store }
    specify { expect(described_class.superclass).to eq GeneralStore }
    context "included modules" do
      specify { expect(described_class.singleton_class.included_modules).to include Forwardable }
    end
    context "initialization" do
      let(:store) { subject.instance_variable_get(:@store) }
      specify { expect(store).to be_a GlobalStore }
      specify { expect(store).to have_key :__api_token_auth__default__store__ }
      specify "default internal store type is HashStore" do
        expect(subject.store).to be_instance_of HashStore
      end
      specify "allows internal store to be passed" do
        expect(described_class.new(internal_store: Hash.new).store).to be_instance_of Hash
      end
      specify "default name is :default_store" do
        expect(subject.instance_variable_get :@name).to eq :__api_token_auth__default__store__
      end
      specify "allows passing a name for store" do
        expect(described_class.new(name: :store).instance_variable_get(:@name)).to eq :__api_token_auth__store__store__
      end
      specify "name is always a symbol" do
        expect(described_class.new(name: "store").instance_variable_get(:@name)).to eq :__api_token_auth__store__store__
      end
      context "#::applications storage default name is :app" do
        specify { expect(subject.name).to eq :__api_token_auth__default__store__ }
      end
      context "store name is prefixed with __api_token_auth__ and suffixed with __store__" do
        specify { expect(described_class.new(name: 'contacts_client').name).to eq :__api_token_auth__contacts_client__store__ }
      end
    end
    context "instance methods" do
      context "#name" do
        let(:store) { described_class.new name: 'store' }
        specify { expect(subject).to respond_to(:name).with(0).arguments }
        specify { expect(subject.name).to eq(:__api_token_auth__default__store__)}
        specify { expect(store.name).to eq(:__api_token_auth__store__store__)}
      end
      context "#rename" do
        subject { described_class.new name: 'store' }
        specify { expect(subject).to respond_to(:rename).with(1).argument }
        specify "rename repo" do
          subject.set :boo, :boo
          expect(subject.get(:boo)).to eq :boo
          store = subject.store
          expect(subject.name).to eq :__api_token_auth__store__store__
          subject.rename '__api_token_bitches__'
          expect(subject.name).to eq :__api_token_bitches__
          expect(subject.store).to eq store
          expect(subject.get(:boo)).to eq :boo
          expect(subject.instance_variable_get(:@store).store.keys).not_to include :__api_token_auth__store__store__
        end
      end
      context "#get" do
        before { store.set :key, :value }
        after  { store.unset :key }
        specify { expect(subject).to respond_to(:get).with(1).argument }
        specify "forwards to store key" do
          expect(store).to receive(:get).with(:key)
          subject.get :key
        end
        specify { expect(subject.get :key).to eq :value }
      end
      context "#set" do
        specify { expect(subject).to respond_to(:set).with(2).arguments }
        specify "forwards to store key" do
          expect(store).to receive(:set).with(:key, :value)
          subject.set :key, :value
        end
        specify "sets key correctly" do
          expect(subject.get :key).to be nil
          subject.set :key, :value
          expect(subject.get :key).to eq :value
        end
      end
      context "#unset" do
        before { subject.set :key, :value }
        specify { expect(subject).to respond_to(:unset).with(1).argument }
        specify "forwards to store" do
          expect(store).to receive(:unset).with(:key)
          subject.unset :key
        end
        specify "unsets :key value" do
          expect(subject.get :key).to eq :value
          subject.unset :key
          expect(subject.get :key).to be nil
        end
      end
      context "#clear" do
        let(:store) { subject.instance_variable_get :@store }
        specify { expect(subject).to respond_to(:clear).with(0).arguments }
        specify "forwards to store" do
          expect(store).to receive(:set).with(:__api_token_auth__default__store__, instance_of(HashStore))
          subject.clear
        end
        specify "store is now empty" do
          subject.set :key, :value
          expect(store.get :__api_token_auth__default__store__).not_to be_empty
          subject.clear
          expect(store.get :__api_token_auth__default__store__).to be_empty
        end
      end
      context "#count" do
        let(:application0) { Store.new name: 'application0' }
        let(:application1) { Store.new name: 'application1' }
        after { subject.clear }
        specify { expect(subject).to respond_to(:count).with(0).arguments }
        specify { expect(subject.count).to eq 0 }
        specify "with some added applications" do
          expect(subject).to be_empty
          subject.add application0
          subject.add application1
          expect(subject).not_to be_empty
          expect(subject.count).to eq 2
        end
      end
      context "#empty?" do
        specify { expect(subject).to respond_to(:empty?).with(0).arguments }
        specify "forwards to store" do
          expect(store).to receive(:empty?)
          subject.empty?
        end
        specify { expect(subject).to be_empty }
      end
      context "#has_key?" do
        before { subject.set :key, :value }
        after  { subject.clear }
        specify { expect(subject).to respond_to(:has_key?).with(1).argument }
        specify "forwards to store" do
          expect(store).to receive(:has_key?).with(:key)
          subject.has_key? :key
        end
        specify { expect(subject).to have_key :key }
      end
      context "#to_hash" do
        let(:person) { HashStore.new }
        before do
          person.set(:name, 'Frank')
          person.set(:age, 34)
          subject.set :name, "name"
          subject.set :enc, "encryption"
          subject.set :person, person
        end
        after { subject.clear }
        specify { expect(subject).to respond_to(:to_hash).with(0).arguments }
        specify "returns a raw native hash with arguments" do
          expect(subject.to_hash).to eq({__api_token_auth__default__store__: {name: "name", enc: "encryption", person: { age: 34, name: "Frank"}}})
        end
      end
      context "#hashify_store" do
        let(:person) { HashStore.new }
        before do
          person.set(:name, 'Frank')
          person.set(:age, 34)
          subject.set :name, "name"
          subject.set :enc, "encryption"
          subject.set :person, person
        end
        after { subject.clear }
        specify { expect(subject).to respond_to(:hashify_store).with(0).arguments }
        specify "returns a raw native hash with arguments" do
          expect(subject.hashify_store).to eq({name: "name", enc: "encryption", person: { age: 34, name: "Frank"} })
        end
      end
      context "#add" do
        let(:application_store) { Store.new }
        before do
          application_store.name= :app0
        end
        after { subject.clear }
        specify { expect(subject).to respond_to(:add).with(1).argument.with_keywords(:force) }
        specify "adds application store" do
          subject.add application_store
          expect(store.get :app0).to eq application_store
        end
        specify "raises error if application is already present" do
          subject.add application_store
          expect { subject.add application_store }.to raise_error StandardError, "there is already an application with the same name in the store"
        end
        specify "allows the option to force the adding of a new application (in case it already exists)" do
          subject.add application_store
          expect { subject.add application_store, force: true }.not_to raise_error
        end
      end
      context "#remove" do
        let(:application_store) { Store.new name: 'app0'}
        before do
          application_store.name= :app0
          subject.add application_store
        end
        after { subject.clear }
        specify { expect(subject).to respond_to(:remove).with(1).argument }
        specify "forwards to store" do
          expect(store).to receive(:unset).with(application_store.name)
          subject.remove application_store
        end
        specify "raises if app does not exist" do
          missing_application_store = Store.new name: 'missing'
          expect { subject.remove missing_application_store }.to raise_error StandardError, "application does not exist in the store"
        end
        specify "removes from store" do
          expect(store).to have_key application_store.name
          subject.remove application_store
          expect(store).not_to have_key application_store.name
        end
      end
      context "#create" do
        after { subject.clear }
        specify { expect(subject).to respond_to(:create).with_keywords(:name) }
        specify "returns create store" do
          expect(subject.create name: 'application_name').to be_instance_of(Store)
        end
        specify "created store is added" do
          subject.create name: 'application_name'
          app = subject.get :application_name
          expect(app).to be_instance_of Store
          expect(app.name).to eq :application_name
        end
        specify "returns created app" do
          expect(subject.create name: 'application_name').to be_instance_of Store
        end
      end
      context "#store" do
        specify { expect(subject).to respond_to(:store).with(0).arguments }
        specify "returns store" do
          expect(subject.store).to eq subject.instance_variable_get(:@store).get(:__api_token_auth__default__store__)
        end
      end
    end
  end
end
