# frozen_string_literal: true

require "address/models/address"
require "address/models/smarty_address"

RSpec.describe Models::SmartyAddress do
  let(:address_hash) do
    {
      street: street,
      city: city,
      state: state,
      zipcode: zipcode,
      plus4_code: "9999"
    }
  end
  let(:street) { "11 any street" }
  let(:city) { "schmitty town" }
  let(:state) { "NH" }
  let(:zipcode) { "828282" }

  describe "#valid?" do
    subject { described_class.new(address_hash).valid? }

    context "when the address is valid" do
      it { is_expected.to eq true }

      context "when city is nil" do
        let(:city) { nil }

        it { is_expected.to eq true }
      end

      context "when state is nil" do
        let(:state) { nil }

        it { is_expected.to eq true }
      end

      context "when zipcode is nil" do
        let(:zipcode) { nil }

        it { is_expected.to eq true }
      end
    end

    context "when the street is nil" do
      let(:street) { nil }

      it { is_expected.to eq false }
    end

    context "when the street is empty" do
      let(:street) { "" }

      it { is_expected.to eq false }
    end

    context "when the street string is too long" do
      let(:street) { build_string(described_class::MaxLength::STREET + 1) }

      it { is_expected.to eq false }
    end

    context "when the city is too long" do
      let(:city) { build_string(described_class::MaxLength::CITY + 1) }

      it { is_expected.to eq false }
    end

    context "when the state is too long" do
      let(:state) { build_string(described_class::MaxLength::STATE + 1) }

      it { is_expected.to eq false }
    end

    context "when the zipcode is too long" do
      let(:zipcode) { build_string(described_class::MaxLength::ZIPCODE + 1) }

      it { is_expected.to eq false }
    end
  end

  describe "#to_cli_format" do
    subject { instance.to_cli_format }

    let(:instance) { described_class.new(address_hash) }
    let(:expected_invalid_address_string) do
      "11 any street, schmitty town, 828282 -> Invalid Address"
    end

    context "when there is no validated address" do
      context "when the validation has been sent" do
        before do
          instance.validation_sent = true
        end

        it "returns the expected invalid address format" do
          expect(subject).to eq expected_invalid_address_string
        end
      end

      context "when the validation has not been sent" do
        let(:expected_not_processed_address_string) do
          "11 any street, schmitty town, 828282 -> Not Processed"
        end

        it "returns the expected not processed address format" do
          expect(subject).to eq expected_not_processed_address_string
        end
      end
    end

    context "when there is a validated address" do
      before do
        instance.validated_address = validated_address
      end

      let(:validated_address) do
        Models::Address.new(validated_address_hash)
      end
      let(:validated_address_hash) do
        {
          street: "11 AnyStreet Rd",
          city: "SmittyTown",
          state: "NH",
          zipcode: "12345",
          plus4_code: "9999"
        }
      end
      let(:expected_valid_cli_format) do
        "11 any street, schmitty town, 828282 -> 11 AnyStreet Rd, SmittyTown, 12345-9999"
      end

      it "returns the expected valid address format" do
        expect(subject).to eq expected_valid_cli_format
      end
    end
  end

  def build_string(length)
    (0...length).map { ("a".."z").to_a[rand(26)] }.join
  end
end
