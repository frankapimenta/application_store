# TODO: check if parent is working ok due to storecomposite store being store and not @store
RSpec.shared_examples "a hash store" do
  after { RequestStore.clear! }
  specify { expect(described_class.included_modules).to include ApplicationStore::Parenthood }
  context "instance_methods" do
    context "#parent" do
      specify { expect(subject).to respond_to(:parent).with(0).arguments }
      specify { expect(subject.parent).to be_falsey }
    end
    context "#parent=" do
      specify { expect(subject).to respond_to(:parent=).with(1).arguments }
      specify "does not assign self to parent if it is nil" do
        parent = nil
        expect(parent).not_to receive(:add)
        subject.parent = parent
      end
      specify "assigns a parent store to the store" do
        parent = ApplicationStore::StoreComposite.new name: 'fake-store-composite'
        expect(subject.parent).to be_falsey
        subject.parent = parent
        expect(subject.parent).to be_truthy
        expect(subject.parent).to be parent
        expect(parent.get(subject.name)).to be subject
      end
    end
    context "on method missing" do
      specify "calls #is_writer?" do
        expect(subject).to receive(:is_writter?).with(:finance_manager)
        subject.finance_manager
      end
      specify "on method missing (reading) forward to #get" do
        expect(subject).to receive(:get).with(:finance_manager)
        subject.finance_manager
      end
      specify "on method missing (writing) forward to #get" do
        hash = {}
        expect(subject).to receive(:set).with(:finance_manager, hash)
        subject.finance_manager=hash
      end
    end
  end
end
