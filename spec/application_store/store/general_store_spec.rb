module ApplicationStore
  RSpec.describe GeneralStore do
    let(:store) { Hash.new }
    subject { described_class.new store }
    specify { expect(described_class).to be_a Class }
    context "initialization" do
      specify { expect(subject.instance_variable_get(:@store)).to eq store }
      specify "raises error if store is nil" do
        expect { described_class.new nil }.to raise_error StandardError, "a store must be set for the store"
      end
    end
    context "instance methods" do
      context "public methods" do
        context "#each" do
          specify { expect(subject).to respond_to(:each).with(0).argument }
          specify { expect { subject.each }.not_to raise_error }
          specify "forwards to store when block given" do
            expect(store).to receive(:each)
            subject.each { |key, val| }
          end
          specify "returns enum if no block is given" do
            expect(subject.each).to be_instance_of Enumerator
          end
        end
        context "#get" do
          specify { expect(subject).to respond_to(:get).with(1).arguments }
          specify { expect { subject.get :name }.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#set" do
          specify { expect(subject).to respond_to(:set).with(2).argument }
          specify { expect { subject.set :name, double(:something) }.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#unset" do
          specify { expect(subject).to respond_to(:unset).with(1).arguments }
          specify { expect { subject.unset :name}.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#clear" do
          specify { expect(subject).to respond_to(:clear).with(0).arguments }
          specify { expect { subject.clear }.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#count" do
          specify { expect(subject).to respond_to(:count).with(0).arguments }
          specify { expect { subject.count }.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#empty?" do
          specify { expect(subject).to respond_to(:empty?).with(0).arguments }
          specify { expect { subject.empty? }.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#has_key?" do
          specify { expect(subject).to respond_to(:has_key?).with(1).argument }
          specify { expect { subject.has_key? :key }.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#to_hash" do
          specify { expect(subject).to respond_to(:to_hash).with(0).arguments }
          specify { expect { subject.to_hash }.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#traverse" do
          specify { expect(subject).to respond_to(:traverse).with(0).arguments }
          specify { expect { subject.traverse }.to raise_error NotImplementedError, "implement method in child class"}
        end
        context "#store" do
          specify { expect(subject).to respond_to(:store).with(0).arguments }
          specify { expect(subject.store).to eq subject.instance_variable_get(:@store) }
        end
      end
    end
  end
end
