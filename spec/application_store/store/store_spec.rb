module ApplicationStore
  RSpec.describe Store do
    it_behaves_like "a hash store"

    specify { expect(described_class.superclass).to be GeneralStore }
    subject { described_class.new(name: 'app0') }
    context "extended modules" do
      specify { expect(described_class.singleton_class.included_modules).to include Forwardable }
    end
    context "on initialization" do
      let(:fake_store_class) do
        FakeStore = Class.new(GeneralStore) do
          def to_hash
          end
        end
      end
      let(:fake_store) { fake_store_class.new([]) } # array as store just to be different than hash store
      specify "does not raise for no store and no parent given" do
        expect { described_class.new }.not_to raise_error
      end
      specify "default store is HashStore" do
        expect(described_class.new.store).to be_kind_of GeneralStore
        expect(described_class.new.store).to be_instance_of HashStore
      end
      specify "gets store from init via dependency injection" do
        expect(described_class.new(fake_store).store).to be_kind_of GeneralStore
      end
      specify "store given is store retrieven" do
        expect(described_class.new(fake_store).store).to eq fake_store
      end
      specify "allows app name on initialization" do
        expect { described_class.new(name: 'app0') }.not_to raise_error
      end
      specify "sets app name on init" do
        expect(subject.name).to eq :app0
      end
      specify "stores parent in @parent" do
        store = double(:store)
        expect(described_class.new(store, parent: store).instance_variable_get(:@parent)).to eq store
      end
    end
    context "public instance methods" do
      let(:store) { subject.instance_variable_get(:@store) }
      context "#each" do
        specify { expect(subject).to respond_to(:each).with(0).argument }
      end
      context "#get" do
        before { subject.set :key, :value }
        after  { subject.unset :key }
        specify { expect(subject).to respond_to(:get).with(1).arguments }
        specify "forwards to store" do
          expect(store).to receive(:get).with(:key)
          subject.get :key
        end
        specify { expect(subject.get(:key)).to eq :value }
      end
      context "#set" do
        after  { subject.unset :key }
        specify { expect(subject).to respond_to(:set).with(2).arguments }
        specify "forwards to store" do
          expect(store).to receive(:set).with(:key, :value)
          subject.set :key, :value
        end
        specify do
          subject.set(:key, :value)
          expect(store.get(:key)).to eq :value
        end
      end
      context "#unset" do
        before { subject.set :key, :value }
        specify { expect(subject).to respond_to(:unset).with(1).argument }
        specify "forwards to store" do
          expect(store).to receive(:unset).with(:key)
          subject.unset :key
        end
        specify do
          subject.unset :key
          expect(subject.get :key).to eq nil
        end
      end
      context "#clear" do
        specify { expect(subject).to respond_to(:clear).with(0).arguments }
        specify "forwards to store" do
          expect(store).to receive(:clear).with(no_args)
          subject.clear
        end
        specify do
          subject.set :key, :value
          expect(store).not_to be_empty
          subject.clear
          expect(store).to be_empty
        end
      end
      context "#to_hash" do
        after { subject.clear }
        specify { expect(subject).to respond_to(:to_hash).with(0).arguments }
        specify "returns a raw native hash with arguments" do
          expect(subject.to_hash).to eq({name: :app0})
        end
      end
      context "#traverse" do
        let(:data)        { described_class.new }
        let(:person)      { described_class.new }
        let(:hash_store)  { described_class.new }
        let(:traversed)   { hash_store.traverse { |k,v| v.respond_to?(:to_hash) ? [k, v.to_hash] : [k,v] } }
        before do
          data.set(:name, "frank")
          data.set(:person, person)
          hash_store.set(:data, data)
        end
        specify { expect(hash_store).to respond_to(:traverse).with(0).arguments }
        specify { expect(traversed.fetch(:data)).to be_instance_of Hash }
        specify "makes changes in deep hash" do
          expect(traversed.dig(:data, :person)).to be_instance_of Hash
        end
      end
      context "attributes" do
        context "#name=" do
          let(:composite) { StoreComposite.new name: 'test-store' }
          specify { expect(subject).to respond_to(:name=).with(1).argument }
          specify "does not set name in parent if there is no parent" do
            parent        = subject.parent

            expect(subject).to receive(:parent).and_return parent
            expect(parent).not_to receive(:set)
            expect(parent).not_to receive(:unsetset)

            subject.name  = "new_name"
          end
          specify "sets name for application store" do
            subject.name= "name"
            expect(subject.get :name).to eq "name".to_sym
          end
          specify "parent changes key with store to store name as well" do
            subject.parent = composite

            parent        = subject.parent
            previous_name = subject.name

            expect(subject).to receive(:parent).at_least(4).times.and_return parent
            expect(parent).to receive(:set).with(:new_name, subject).and_return parent
            expect(parent).to receive(:unset).with(previous_name)
            # expect(subject.get :name).to eq "new_name".to_sym
            # expect(subject.parent.get(:new_name)).to be subject

            subject.name  = "new_name"

            subject.parent.destroy!
          end
          specify "changes name effectively" do
            subject.parent = composite
            expect(subject.name).to eq :app0
            subject.name = 'new_name'
            expect(subject.name).to eq :new_name
            expect(subject.parent.get(:new_name)).to be subject
            expect(subject.parent.new_name).to be subject
          end
        end
        context "#name" do
          before { subject.name= "name" }
          specify { expect(subject).to respond_to(:name).with(0).arguments }
          specify "gets name from ivar @name" do
            expect(subject.name).to eq "name".to_sym
          end
        end
      end
    end
  end
end
