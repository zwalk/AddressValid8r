# frozen_string_literal: true

require_relative "valid8r/version"
require "address/clients/smarty_client"
require "address/input/address_file_parser"

module Address
  ## Valid8r
  # Intended to be the module that begins the validation and outputs the result
  module Valid8r
    class Error < StandardError; end

    def self.process(file_path)
      addresses = Input::AddressFileParser.parse(file_path)

      if addresses.empty?
        puts "No Addresses found to be valid8d."
      elsif addresses.size > 100
        puts "More than 100 Addresses at a time not supported."
      else
        Clients::SmartyClient.new.validate_addresses(addresses).each do |address|
          puts address.to_cli_format
        end
      end
    end
  end
end
