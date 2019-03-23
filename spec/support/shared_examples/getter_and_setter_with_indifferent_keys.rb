RSpec.shared_examples "a getter and setter with indifferent keys" do

  context "#get" do
    before do
      subject.set :key, :value
      expect(store).to have_key :key
    end
    after do
      subject.unset :key
      expect(store).not_to have_key :key
    end

    specify { expect(subject).to respond_to(:get).with(1).argument }
    specify "gets value for given key" do
      expect(subject.get :key).to eq :value
    end
    specify "gets it via string key" do
      expect(subject.get "key").to eq :value
    end
    specify "does not raise error for no existing key" do
      expect { subject.get :no_existing_key }.not_to raise_error
    end
    specify "returns nil for inexistence key" do
      expect(subject.get :no_existing_key).to be nil
    end
  end
  context "#[]" do
    specify { expect(subject).to respond_to(:[]).with(1).argument }
    specify "forwards to #get" do
      expect(subject).to receive(:get).with(:key)
      subject[:key]
    end
  end
  context "#set" do
    specify { expect(subject).to respond_to(:set).with(2).argument }
    specify "has key and value after set" do
      subject.set :key, :value
      expect(subject.get(:key)).to eq :value
    end
    specify "has key and value after setting via string key" do
      subject.set "key", :value
      expect(subject.get "key").to eq :value
    end
  end
  context "#unset" do
    specify { expect(subject).to respond_to(:unset).with(1).argument }
    specify "unsets key (removes key and value from repo)" do
      subject.set :key, :value
      expect(store).to have_key :key
      subject.unset :key
      expect(store).not_to have_key :key
    end
    specify "unsets key via (string key)" do
      subject.set :key, :value
      expect(store).to have_key :key
      subject.unset "key"
      expect(store).not_to  have_key :key
    end
  end
end
