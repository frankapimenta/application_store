RSpec.shared_examples "a hash store" do
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
