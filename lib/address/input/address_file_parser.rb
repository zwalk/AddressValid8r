# frozen_string_literal: true

require "address/models/smarty_address"
require "csv"

module Address
  module Input
    ##
    # AddressFileParser handles converting a CSV of addresses into SmartyAddress objects
    class AddressFileParser
      class NoFilePathProvidedError < StandardError; end

      class << self
        def parse(file_path, options = {})
          raise NoFilePathProvidedError if file_path.nil?

          addresses_from_csv(file_path, options)
        rescue Errno::ENOENT, NoFilePathProvidedError, Errno::EISDIR
          print_file_not_found file_path
          []
        end

        private

        def addresses_from_csv(file_path, options = {})
          return [] if file_path.nil?

          addresses = []

          CSV.foreach(
            file_path,
            headers: options.fetch(:headers, true),
            header_converters: :symbol
          ) do |row|
            addresses << build_smarty_address(row)
          end

          addresses
        end

        def build_smarty_address(row)
          Models::SmartyAddress.new({
                                      street: row[:street]&.strip,
                                      city: row[:city]&.strip,
                                      state: row[:state]&.strip,
                                      zipcode: row[:zip_code]&.strip
                                    })
        end

        def print_file_not_found(file_path)
          puts "File not found at: #{file_path}"
        end
      end
    end
  end
end
