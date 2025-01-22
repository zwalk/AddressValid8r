# frozen_string_literal: true

require 'address/input/address_file_parser'

RSpec.describe Address::Input::AddressFileParser do
  describe '#parse' do
    subject { described_class.parse file_path }

    shared_examples 'a file path that does exist' do
      it 'returns the expected array of addresses' do
        expect(subject).to eq expected_result
      end
    end

    context 'when the file exists' do
      let(:file_path) { './spec/fixtures/valid_address_input.csv' }
      let(:expected_result) { [address] }
      let(:address) do
        Models::SmartyAddress.new(
          {
            street: '123 rocky road',
            city: 'atlantis',
            zipcode: '55555'
          }
        )
      end

      it_behaves_like 'a file path that does exist'

      context 'when the file is empty' do
        let(:file_path) { './spec/fixtures/empty.csv' }
        let(:expected_result) { [] }

        it_behaves_like 'a file path that does exist'
      end
    end

    shared_examples 'a file path that does not exist' do
      let(:expected_error_message) { "File not found at: #{file_path}\n" }

      it 'prints the expected error message' do
        expect { subject }.to output(expected_error_message).to_stdout
      end

      it { is_expected.to eq [] }
    end

    context 'when the file path is a string but does not lead to a valid file' do
      let(:file_path) { '/invalid/path' }

      it_behaves_like 'a file path that does not exist'
    end

    context 'when the file path is an empty string' do
      let(:file_path) { '' }

      it_behaves_like 'a file path that does not exist'
    end

    context 'when the file path is nil' do
      let(:file_path) { nil }

      it_behaves_like 'a file path that does not exist'
    end

    context 'when CSV throws an Errno::ENOENT error' do
      before do
        allow(CSV).to receive(:foreach).and_raise(Errno::ENOENT)
      end

      let(:file_path) { nil }

      it_behaves_like 'a file path that does not exist'
    end

    context 'when CSV throws an Errno::EISDIR error' do
      before do
        allow(CSV).to receive(:foreach).and_raise(Errno::EISDIR)
      end

      let(:file_path) { nil }

      it_behaves_like 'a file path that does not exist'
    end
  end
end
