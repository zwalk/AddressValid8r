# frozen_string_literal: true

require "address/models/address"
require "address/models/smarty_address"
require "json"
require "net/http"
require "securerandom"
require "uri"

RSpec.describe Clients::SmartyClient do
  before do
    $stdout = output
    allow(Net::HTTP).to receive(:new).and_return(mocked_net_http)
    allow(mocked_net_http).to receive(:use_ssl=).and_return(nil)
    allow(mocked_net_http).to receive(:request).and_return(mocked_net_http_response)
    allow(Net::HTTP::Post).to receive(:new).and_return(mocked_net_http_post)
    allow(mocked_net_http_response).to receive(:body).and_return(body)
    allow(ENV).to receive(:[]).with("AUTH_ID").and_return("AUTH_ID")
    allow(ENV).to receive(:[]).with("AUTH_TOKEN").and_return("AUTH_TOKEN")
    allow(ENV).to receive(:[]).with("LICENSE_TYPE").and_return("LICENSE_TYPE")
    allow(SecureRandom).to receive(:uuid).and_return(key_value)
    allow(JSON).to receive(:parse).and_call_original
  end

  after do
    $stdout = STDOUT
  end

  let(:mocked_net_http) do
    instance_double(Net::HTTP)
  end
  let(:mocked_net_http_response) do
    instance_double(Net::HTTPResponse, code: code)
  end
  let(:code) { "200" }
  let(:body) { JSON.generate(response) }
  let(:output) { StringIO.new }
  let(:mocked_net_http_post) do
    Net::HTTP::Post.new(URI("https://www.some_uri.com"), described_class::HEADERS)
  end
  let(:request_uri) do
    URI("https://us-street.api.smarty.com/street-address?auth-id=AUTH_ID&auth-token=AUTH_TOKEN&license=LICENSE_TYPE")
  end
  let(:response) do
    [
      {
        input_id: input_id,
        # rubocop disable is necessary to keep this symbol matched to the API response structure
        delivery_line_1: street, # rubocop:disable Naming/VariableNumber
        components: {
          city_name: city,
          state_abbreviation: state,
          zipcode: zipcode,
          plus4_code: plus4_code
        }
      }
    ]
  end
  let(:input_id) { 1 }
  let(:street) { "5678 whodoyouappreciate blvd" }
  let(:city) { "Richmond" }
  let(:state) { "NY" }
  let(:zipcode) { "19106" }
  let(:plus4_code) { "9876" }
  let(:key_value) { 5 }

  describe "#validate_addresses" do
    subject { described_class.new.validate_addresses(addresses) }

    context "when addresses is empty" do
      let(:addresses) { [] }

      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "when there are addresses to validate" do
      before(:each) do
        subject
      end

      let(:input_id) { 5 }
      let(:addresses) { [address] }
      let(:address) { Models::SmartyAddress.new(address_data) }
      let(:address_data) do
        {
          street: "567 whodoyouappreciate blvd",
          city: "Richmond",
          state: "NY",
          zipcode: "19106"
        }
      end
      let(:expected_request_body) do
        [address.to_hash.merge(input_id: 5, candidates: 1)].to_json
      end

      it "should call http.request" do
        expect(mocked_net_http).to have_received(:request).with(mocked_net_http_post)
      end

      it "should build the expected request body" do
        expect(mocked_net_http_post.body).to eq expected_request_body
      end

      it "calls JSON to parse the response body" do
        expect(JSON).to have_received(:parse)
      end

      it "sets the address processed to validation_sent equals true" do
        expect(address.validation_sent).to eq true
      end

      context "when there is a matching result" do
        let(:expected_validated_address) do
          Models::Address.new(
            street: street,
            city: city,
            state: state,
            zipcode: zipcode,
            plus4_code: plus4_code
          )
        end

        it "sets that result to the validated_address" do
          expect(address.validated_address).to eq expected_validated_address
        end
      end

      context "when there is no matching result" do
        let(:key_value) { 0 }

        it "maintains validated_address as nil" do
          subject
          expect(address.validated_address).to be_nil
        end
      end
    end

    context "when the call is not a successful response" do
      let(:addresses) { [address] }
      let(:address) { Models::SmartyAddress.new(address_data) }
      let(:address_data) do
        {
          street: "567 whodoyouappreciate blvd",
          city: "Richmond",
          state: "NY",
          zipcode: "19106"
        }
      end
      let(:code) { "500" }
      let(:body) { "hawaiian pizza is pretty good" }

      it "prints the expected error message" do
        subject
        expect(output.string).to eq "Something went wrong.\nstatus: #{code}, error: #{body}\n"
      end
    end
  end
end
