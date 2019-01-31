module ApplicationStore
  RSpec.describe Store do
    specify { expect(described_class.superclass).to be GeneralStore }
    subject { described_class.new(name: 'app0') }
    context "extended modules" do
      specify { expect(described_class.singleton_class.included_modules).to include Forwardable }
    end
    context "initialization" do
      let(:fake_store_class) do
        FakeStore = Class.new(GeneralStore) do
          def to_hash
          end
        end
      end
      let(:fake_store) { fake_store_class.new([]) } # array as store just to be different than hash store
      specify { expect { described_class.new }.not_to raise_error }
      specify "default store is HashStore" do
        expect(described_class.new.instance_variable_get(:@store)).to be_kind_of GeneralStore
        expect(described_class.new.instance_variable_get(:@store)).to be_instance_of HashStore
      end
      specify "gets store from init via dependency injection" do
        expect(described_class.new(fake_store).instance_variable_get(:@store)).to be_kind_of GeneralStore
      end
      specify "allows app data on initialization" do
        expect { described_class.new(name: 'app0') }.not_to raise_error
      end
      specify "sets app data on init" do
        expect(subject.name).to eq :app0
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
      context "attributes" do
        context "#name=" do
          specify { expect(subject).to respond_to(:name=).with(1).argument }
          specify "sets name for application store" do
            subject.name= "name"
            expect(subject.get :name).to eq "name".to_sym
          end
        end
        context "#name" do
          specify { expect(subject).to respond_to(:name).with(0).arguments }
          specify "gets name from ivar @name" do
            subject.name= "name"
            expect(subject.name).to eq "name".to_sym
          end
        end
      end
    end
  end
end
