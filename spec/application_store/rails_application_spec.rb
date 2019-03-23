module ApplicationStore
  RSpec.describe RailsApplication do
    let!(:rails_constant)              { class_double('Rails').as_stubbed_const(:transfer_nested_constants => true) }
    let!(:rails_application_constant)  { class_double('Rails::Application').as_stubbed_const(:transfer_nested_constants => true) }
    let(:rails_application_instance)    { double(:rails_application_instance, is_a?: true) }
    context "on initialization" do
      specify "raises error if not initialized with a rails app" do
        allow(rails_application_instance).to receive(:is_a?).and_return false
        expect { described_class.new ApplicationStore }.to raise_error StandardError, "you have to initialize with a Rails application"
      end
      specify "initializes with a rails application" do
        expect { described_class.new rails_application_instance }.not_to raise_error
      end
      specify "holds rails_application in @rails_application" do
        expect(described_class.new(rails_application_instance).rails_application).to eq rails_application_instance
      end
    end
    context "#rails_application" do
      subject { described_class.new rails_application_instance }
      specify { expect(subject).to respond_to(:rails_application).with(0).arguments }
      specify { expect(subject.rails_application).to eq rails_application_instance }
    end
    context "on method missing" do
      subject { described_class.new rails_application_instance }
      let(:config)  { double(:config) }
      specify "for writters" do
        expect(subject).to receive(:rails_application).once.and_return rails_application_instance
        expect(rails_application_instance).to receive(:config).and_return config
        expect(config).to receive(:host=).with(1)
        subject.host = 1
      end
      context "for readers" do
        context "forward to config or to :config_for" do
          specify "forwarding to config" do
            expect(subject).to receive(:rails_application).twice.and_return rails_application_instance
            expect(rails_application_instance).to receive(:config).twice.and_return config
            expect(config).to receive(:respond_to?).and_return true
            expect(config).to receive(:__send__).with(:host)
            expect(rails_application_instance).not_to receive(:config_for)
            subject.host
          end
          specify "forwarding to config_for" do
            expect(subject).to receive(:rails_application).twice.and_return rails_application_instance
            expect(rails_application_instance).to receive(:config).once.and_return config
            expect(config).to receive(:respond_to?).and_return false
            expect(config).not_to receive(:__send__)
            expect(rails_application_instance).to receive(:config_for).with(:host).and_return config
            subject.host
          end
        end
      end
    end
  end
end
