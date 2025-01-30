# frozen_string_literal: true

require "auth/authorizer"
require "dotenv"

RSpec.describe Authorizer do
  before do
    $stdout = output
    allow($stdin).to receive(:gets).and_return(OpenStruct.new(chomp: "hello_world"))
    allow(File).to receive(:open) { |&block| block.call(mocked_file) }
    stub_const("ENV", env_mock)
  end

  after do
    $stdout = STDOUT
  end

  let(:output) { StringIO.new }
  let(:mocked_file) { StringIO.new }
  let(:env_mock) do
    { "AUTH_ID" => auth_id, "AUTH_TOKEN" => auth_token, "LICENSE_TYPE" => license_type }
  end
  let(:auth_id) { nil }
  let(:auth_token) { nil }
  let(:license_type) { nil }

  describe "#authorize" do
    subject { described_class.authorize }

    before(:each) do
      subject
    end

    [
      {
        auth_id: nil,
        auth_token: nil,
        license_type: nil,
        expected_message: "Enter your Auth id:\nEnter your Auth token:\nEnter your License type:\n",
        expected_file_writes: "AUTH_ID=hello_world\nAUTH_TOKEN=hello_world\nLICENSE_TYPE=hello_world\n"
      },
      {
        auth_id: nil,
        auth_token: "",
        license_type: "someValue",
        expected_message: "Enter your Auth id:\nEnter your Auth token:\n",
        expected_file_writes: "AUTH_ID=hello_world\nAUTH_TOKEN=hello_world\n"
      },
      {
        auth_id: nil,
        auth_token: "authValue",
        license_type: nil,
        expected_message: "Enter your Auth id:\nEnter your License type:\n",
        expected_file_writes: "AUTH_ID=hello_world\nLICENSE_TYPE=hello_world\n"
      },
      {
        auth_id: nil,
        auth_token: "authValue",
        license_type: "someValue",
        expected_message: "Enter your Auth id:\n",
        expected_file_writes: "AUTH_ID=hello_world\n"
      },
      {
        auth_id: "anyValue",
        auth_token: nil,
        license_type: "",
        expected_message: "Enter your Auth token:\nEnter your License type:\n",
        expected_file_writes: "AUTH_TOKEN=hello_world\nLICENSE_TYPE=hello_world\n"
      },
      {
        auth_id: "anyValue",
        auth_token: nil,
        license_type: "someValue",
        expected_message: "Enter your Auth token:\n",
        expected_file_writes: "AUTH_TOKEN=hello_world\n"
      },
      {
        auth_id: "anyValue",
        auth_token: "authValue",
        license_type: nil,
        expected_message: "Enter your License type:\n",
        expected_file_writes: "LICENSE_TYPE=hello_world\n"
      },
      {
        auth_id: "anyValue",
        auth_token: "authValue",
        license_type: "someValue",
        expected_message: "",
        expected_file_writes: ""
      }
    ].each do |options|
      context "when auth_id is #{options[:auth_id]}, "\
              "auth_token is #{options[:auth_token]} "\
              "and license type is #{options[:license_type]}" do
        let(:auth_id) { options[:auth_id] }
        let(:auth_token) { options[:auth_token] }
        let(:license_type) { options[:license_type] }

        it "should output the right message" do
          expect(output.string).to eq options[:expected_message]
        end

        it "should call to add the expected file lines" do
          expect(mocked_file.string).to eq options[:expected_file_writes]
        end
      end
    end
  end

  describe "#reset" do
    subject { described_class.reset }

    before do
      allow(mocked_file).to receive(:truncate).and_return(nil)
    end

    let(:mocked_file) { double(File) }

    it "calls to open the env file" do
      expect(File).to receive(:open).with(described_class::ENV_FILE_PATH, described_class::WRITE)
      subject
    end

    it "calls to truncate the file" do
      expect(mocked_file).to receive(:truncate).with(0)
      subject
    end
  end
end
