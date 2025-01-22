# frozen_string_literal: true

require 'address/input/address_file_parser'

RSpec.describe Address::Valid8r do
  it "has a version number" do
    expect(Address::Valid8r::VERSION).not_to be nil
  end

  before do
    $stdout = output
    allow(Address::Input::AddressFileParser).to receive(:parse).and_return(addresses)
    allow(Clients::SmartyClient).to receive(:validate_addresses).and_return(validated_addresses)
  end

  after do
    $stdout = STDOUT
  end

  let(:output) { StringIO.new }
  let(:file_path) { '/some/path' }
  let(:addresses) { [address] }
  let(:address) do
    Models::SmartyAddress.new(address_data)
  end
  let(:address_data) do
    {
      street: street,
      city: city,
      state: state,
      zipcode: zipcode,
      plus4_code: '9999'
    }
  end
  let(:street) { '11 any street' }
  let(:city) { 'schmitty town' }
  let(:state) { 'NH' }
  let(:zipcode) { '828282' }
  let(:validated_addresses) { addresses }

  describe '#process' do
    subject { described_class.process(file_path) }

    context 'when there parse is successful' do
      before do
        allow(validated_addresses.first).to receive(:to_cli_format).and_return("hawaiian pizza is good")
      end

      it 'calls Input::FileParser' do
        expect(Address::Input::AddressFileParser).to receive(:parse).with(file_path)
        subject
      end

      it 'prints the cli_format' do
        subject
        expect(output.string).to eq "hawaiian pizza is good\n"
      end
    end

    context 'when the addresses is empty' do
      let(:addresses) { [] }

      it 'calls Input::FileParser' do
        expect(Address::Input::AddressFileParser).to receive(:parse).with(file_path)
        subject
      end

      it 'prints that there were no addresses' do
        subject
        expect(output.string).to eq "No Addresses found to be valid8d.\n"
      end
    end

    context 'when there are too many addresses to process at once' do
      let(:addresses) { (0..100).to_a }

      it 'calls Input::FileParser' do
        expect(Address::Input::AddressFileParser).to receive(:parse).with(file_path)
        subject
      end

      it 'prints that there were too many addresses' do
        subject
        expect(output.string).to eq "More than 100 Addresses at a time not supported.\n"
      end
    end
  end
end
