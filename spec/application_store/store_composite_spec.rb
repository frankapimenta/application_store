module ApplicationStore
  RSpec.describe StoreComposite do
    it_behaves_like "a hash store"

    let(:store) { subject.store }
    specify { expect(described_class.superclass).to eq GeneralStore }
    context "included modules" do
      specify { expect(described_class.singleton_class.included_modules).to include Forwardable }
    end
    context "initialization" do
      let(:store) { subject.instance_variable_get(:@store) }
      specify { expect(store).to be_a GlobalStore }
      specify { expect(store).to have_key :__default__store__ }
      specify "default internal store type is HashStore" do
        expect(subject.store).to be_instance_of HashStore
      end
      specify "allows internal store to be passed" do
        expect(described_class.new(internal_store: Hash.new).store).to be_instance_of Hash
      end
      specify "default name is :default_store" do
        expect(subject.name).to eq :__default__store__
      end
      specify "allows passing a name for store" do
        expect(described_class.new(name: :store).name).to eq :__store__store__
      end
      specify "name is always a symbol" do
        expect(described_class.new(name: "store").name).to eq :__store__store__
      end
      context "store name is prefixed with __ and suffixed with __store__" do
        specify { expect(described_class.new(name: 'contacts_client').name).to eq :__contacts_client__store__ }
      end
      context "sets @destroyed as false" do
        specify { expect(subject.instance_variable_get(:@destroyed)).to eq false }
      end
    end
    context "instance methods" do
      context "#destroyed?" do
        specify { expect(subject).to respond_to(:destroyed?).with(0).arguments }
        specify "is not destroyed after initialization" do
          expect(subject.destroyed?).to eq false
        end
        specify "is #destroyed? after destroyed" do
          subject.destroy!
          expect(subject.destroyed?).to eq true
        end
      end
      context "#name" do
        let(:store) { described_class.new name: 'store' }
        specify { expect(subject).to respond_to(:name).with(0).arguments }
        specify { expect(subject.name).to eq(:__default__store__)}
        specify { expect(store.name).to eq(:__store__store__)}
      end
      context "#rename" do
        after { subject.destroy! }
        subject { described_class.new(name: 'store') }
        specify { expect(subject).to respond_to(:rename).with(1).argument }
        specify "rename repo" do
          subject.set :boo, :boo
          expect(subject.get(:boo)).to eq :boo
          store = subject.store
          expect(subject.name).to eq :__store__store__
          subject.rename '__api_token_bitches__'
          expect(subject.name).to eq :__api_token_bitches__
          expect(subject.store).to eq store
          expect(subject.get(:boo)).to eq :boo
          expect(subject.instance_variable_get(:@store).store.keys).not_to include :__store__store__
          expect(subject.instance_variable_get(:@store).store.keys).to include :__api_token_bitches__
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
          expect(store).to receive(:set).with(:__default__store__, instance_of(HashStore))
          subject.clear
        end
        specify "store is now empty" do
          subject.set :key, :value
          expect(store.get :__default__store__).not_to be_empty
          subject.clear
          expect(store.get :__default__store__).to be_empty
        end
      end
      context "#destroy!" do
        let(:store) { subject.instance_variable_get(:@store) }
        specify { expect(subject).to respond_to(:destroy!).with(0).arguments }
        specify "forwards to store call to #clear" do
          expect(store).to receive(:clear)
          subject.destroy!
        end
        specify "empties Global Store" do
          subject.add ApplicationStore::Store.new name: 'to-delete-store'
          expect(store).not_to be_empty
          subject.destroy!
          expect(store).to be_empty
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
          expect(subject.to_hash).to eq({__default__store__: {name: "name", enc: "encryption", person: { age: 34, name: "Frank"}}})
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
        let(:store)             { Store.new name: 'store' }
        let(:same_name_store)   { Store.new name: store.name }
        let(:other_store)       { Store.new name: 'other-store' }
        let(:different_parent)  { StoreComposite.new name: 'other-store-composite' }
        after do
          # subject.remove store
          # subject.remove same_name_store
          # store.parent           = nil
          # same_name_store.parent = nil
          # other_store.parent     = nil
          # subject.destroy!
        end
        specify { expect(subject).to respond_to(:add).with(1).argument.with_keywords(:force) }
        context "when parent is inexistant" do
          specify "raises error if there are stores with the same name" do
            subject.add store
            expect { subject.add same_name_store }.to raise_error "a store with same name already exists"
          end
        end
        context "when parent is the same" do
          specify "skips adding if there are no stores with the same name" do
            store.parent       = subject
            other_store.parent = subject
            expect(other_store).not_to receive(:parent=)
            expect(subject).not_to receive(:set)
            expect { subject.add other_store }.not_to raise_error
          end
          xspecify "skips adding if a store with the same name exists" do
            #same_name has no parent when adding subject it already exists
            store.parent           = subject
            same_name_store.parent = subject
            expect(same_name_store).not_to receive(:parent=)
            expect(subject).not_to receive(:set)
            expect { subject.add same_name_store }.not_to raise_error
          end
        end
        context "when parent is different" do
          specify "raises error if a store with the same name exists" do
            # store            = Store.new name: 'name', parent: subject
            # different_parent = StoreComposite.new name: 'other-store-composite'
            # allow(different_parent).to receive(:set)
            # same_name_store  = Store.new name: store.name, parent: different_parent

            store.parent           = subject
            same_name_store.parent = different_parent
            expect { subject.add same_name_store }.to raise_error "a store with same name already exists"
          end
          specify "replaces store if a store with the same name exists and force option is true (old parent has to have store removed, old store has to be destroyed)" do
            store.parent = subject
            allow(different_parent).to receive(:set)
            same_name_store.parent = different_parent
            expect { subject.add same_name_store, force: true }.not_to raise_error
            expect(store.parent).to be_falsey
            expect(same_name_store.parent).to be subject.store
            expect(subject.count).to eq 1
          end
          specify "adds store if there are no stores with the same name (old parent has to have the store removed)" do
            store.parent = subject
            allow(different_parent).to receive(:set)
            other_store.parent = different_parent
            expect { subject.add other_store }.not_to raise_error
            expect(other_store.parent).to be subject.store
            expect(subject.count).to eq 2
          end
          specify "returns added store" do
            store.parent = subject
            other_store.parent = different_parent
            expect(subject.add other_store).to eq other_store
          end
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
        specify "sets parent to nil when removing" do
          subject.remove application_store
          expect(application_store.parent).to be_falsey
        end
        specify "returns removed store" do
          expect(subject.remove application_store).to eq application_store
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
        specify "has self as parent" do
          app_store = subject.create(name: 'application_name')
          expect(subject.get(app_store.name).parent).to be subject.store
        end
      end
      context "#store" do
        specify { expect(subject).to respond_to(:store).with(0).arguments }
        specify "returns store" do
          expect(subject.store).to eq subject.instance_variable_get(:@store).get(:__default__store__)
        end
      end
    end
  end
end
