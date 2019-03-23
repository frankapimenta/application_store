module ApplicationStore
  RSpec.describe HashStore do
    it_behaves_like "a getter and setter with indifferent keys"
    it_behaves_like "a hash store"
    # TODO hash store has to have a name because of #parent= spec tests in shared example
    before { subject.set :name, 'hash-store'}
    let(:store) { subject.store }
    specify { expect(described_class.superclass).to eq GeneralStore }
    specify { expect{ described_class.new }.not_to raise_error }
    context "extended modules" do
      specify { expect(described_class.singleton_class.included_modules).to include Forwardable }
    end
    context "included modules" do
      specify { expect(described_class.included_modules).to include Enumerable }
    end
    context "initialization" do
      specify "with default store" do
        expect(subject.store).to be_instance_of Hash
      end
      specify "store is given via args" do
        store = {}
        expect(described_class.new(store).store).to eq store
      end
      specify "stores parent in @parent" do
        store = {}
        expect(described_class.new(store, parent: store).instance_variable_get(:@parent)).to eq store
      end
    end
    context "instance methods" do
      after { subject.instance_variable_set(:@store, Hash.new) }
      context "#each" do
        specify { expect(subject).to respond_to(:each).with(0).argument }
      end
      context "#clear" do
        before do
          subject.set :key0, :value0
          subject.set :key1, :value1
          subject.set :key2, :value2
        end
        specify { expect(subject).to respond_to(:clear).with(0).arguments }
        specify "clears hash" do
          expect(subject).not_to be_empty
          expect(subject.store.keys).to eq([:name, :key0, :key1, :key2])
          expect(subject.clear)
          expect(subject).to be_empty
        end
      end
      context "#empty?" do
        before { subject.unset :name }
        specify { expect(subject).to respond_to(:empty?).with(0).arguments }
        specify "asserts emptyness of store" do
          expect(subject).to be_empty
        end
      end
      context "#has_key?" do
        before { subject.set :key, :value }
        after  { subject.unset :key }
        specify { expect(subject).to respond_to(:has_key?).with(1).arguments }
        specify "asserts emptyness of store" do
          expect(subject).to have_key :key
        end
      end
      context "#traverse" do
        let(:data)        { HashStore.new }
        let(:person)      { HashStore.new }
        let(:hash_store)  { HashStore.new }
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
      context "#to_hash" do
        after { subject.clear }
        specify { expect(subject).to respond_to(:to_hash).with(0).arguments }
        specify "calls #traverse" do
          expect(subject).to receive(:traverse)
          subject.to_hash
        end
        specify "returns a raw native hash with arguments" do
          subject.set :name, "name"
          subject.set :enc, "encryption"
          expect(subject.to_hash).to eq({name: "name", enc: "encryption" })
        end
      end
    end
  end
end
