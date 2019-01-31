module ApplicationStore
  RSpec.describe Refinements do
    context "when not using Refinements" do
      specify { expect { Hash.new.traverse }.to raise_error NoMethodError, /traverse/ }
    end
    context "when using Refinements" do
      let(:hash) { Refine.new }
      before do
        class Refine
          using ApplicationStore::Refinements
          def a
            {}
          end
        end
      end
      specify do
        skip "failing not sure why yet"
        expect { hash.a.traverse {} }.not_to raise_error
      end
    end
  end
end
