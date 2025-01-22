# frozen_string_literal: true

require 'address/models/address'
require 'securerandom'

RSpec.describe Models::Address do

  let(:instance) { described_class.new address }
  let(:address) do
    {
      street: '123 Main St',
      city: 'Anytown',
      state: 'OH',
      zipcode: '55555',
      plus4_code: '1234',
    }
  end

  context 'when initialized with valid attributes' do
    describe '#street' do
      subject { instance.street }

      it { is_expected.to eq '123 Main St' }
    end

    describe '#city' do
      subject { instance.city }

      it { is_expected.to eq 'Anytown' }
    end

    describe '#state' do
      subject { instance.state }

      it { is_expected.to eq 'OH' }
    end

    describe '#zipcode' do
      subject { instance.zipcode }

      it { is_expected.to eq '55555' }
    end

    describe '#plus4_code' do
      subject { instance.plus4_code }

      it { is_expected.to eq '1234' }
    end
  end

  describe '#to_hash' do
    subject { instance.to_hash }

    before do
      allow(SecureRandom).to receive(:uuid).and_return('123-456')
    end

    context 'when initialized with valid attributes' do
      let(:expected_hash) { address.merge(key: '123-456') }

      it 'should reformat the values to a simple hash' do
        expect(subject).to eq expected_hash
      end
    end

    context 'when initialized with invalid attributes' do
      let(:address) do
        {
          street: nil,
          city: '',
          state: 800,
          zipcode: "",
          plus4_code: "",
        }
      end
      let(:expected_hash) do
        {
          key: '123-456',
          street: '',
          city: '',
          state: 800,
          zipcode: "",
          plus4_code: "",
        }
      end

      it 'should return a hash with values provided but convert nil to an empty string' do
        expect(subject).to eq expected_hash
      end
    end
  end

  describe '#==' do
    subject { instance == other_instance }
    let(:other_instance) do
      described_class.new other_address
    end

    context 'when the properties are all the same' do
      let(:other_address) { address }

      it { is_expected.to eq true}
    end

    context 'when the properties are different' do
      let(:other_address) do {
        street: '321 Last St',
        city: 'SomeTown',
        state: 'CA',
        zipcode: '11111',
        plus4_code: '4444',
      }
      end

      it { is_expected.to eq false }
    end
  end
end
