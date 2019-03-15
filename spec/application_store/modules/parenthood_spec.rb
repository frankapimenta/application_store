module ApplicationStore
  RSpec.describe Parenthood do
    let(:described_class) do
      class FakeStore < Store
        include Parenthood
      end
    end
    let(:subject) { described_class.new name: 'fake-store' }
    it_behaves_like "a hash store"
  end
end
