RSpec.describe ConfigurationFile do
  subject { described_class.new(location_path: location_path, file_name: file_name) }

  let(:config_class)            { ApplicationStore::Config }
  let(:location_path)           { config_class.config_path }
  let(:file_name)               { 'configuration.yml' }
  let(:file_path) { "#{location_path}/#{file_name}" }

  context "on initialization" do
    specify "holds location_path given in @location_path" do
      expect(subject.instance_variable_get(:@location_path)).to eq location_path
    end
    specify "holds file_name given in @file_name" do
      expect(subject.instance_variable_get(:@file_name)).to eq file_name
    end
    specify "raises error if file_name is not given" do
      expect { described_class.new }.to raise_error
    end
    specify "has Config.config_path as default config_path" do
      expect(described_class.new(file_name: file_name).instance_variable_get(:@location_path)).to eq location_path
    end
  end
  context "instance methods" do
    context "#location_path" do
      specify { expect(subject).to respond_to(:location_path).with(0).arguments }
      specify { expect(subject.location_path).to eq location_path }
    end
    context "#file_name" do
      specify { expect(subject).to respond_to(:file_name).with(0).arguments }
      specify { expect(subject.file_name).to eq file_name }
    end
    context "#exists?" do
      specify { expect(subject).to respond_to(:exists?).with(0).arguments }
      context "expectations calls" do
        specify "calls #file_path" do
          expect(subject).to receive(:file_path).and_call_original
          subject.exists?
        end
      end
      specify "does not exist (configuration file)" do
        subject.instance_variable_set(:@file_name, 'confiuration.yml')

        expect(subject.exists?).to eq false
      end
      specify { expect(subject.exists?).to eq true }
    end
    context "#file_path" do
      specify { expect(subject).to respond_to(:file_path).with(0).arguments }
      context "expectations calls" do
        specify "calls File.join" do
          expect(File).to receive(:join).with(location_path, file_name).and_call_original
          subject.file_path
        end
      end
      specify { expect(subject.file_path).to eq(file_path) }
    end
  end
end
