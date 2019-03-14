RSpec.shared_examples "a hash store" do
  context "instance_methods" do
    context "#parent" do
      specify { expect(subject).to respond_to(:parent).with(0).arguments }
      specify { expect(subject.parent).to be_falsey }
    end
    context "#parent=" do
      specify { expect(subject).to respond_to(:parent=).with(1).arguments }
      specify "assigns a parent store to the store" do
        parent = double :parent
        expect(subject.parent).to be_falsey
        subject.parent = parent
        expect(subject.parent).to be_truthy
        expect(subject.parent).to be parent
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
