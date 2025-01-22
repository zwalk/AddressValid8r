# frozen_string_literal: true

require 'address/models/smarty_address'
require "csv"

module Address
  module Input
    class AddressFileParser
      class NoFilePathProvidedError < StandardError; end
      def self.parse(file_path, options = {})
        begin
          raise NoFilePathProvidedError if file_path.nil?

          addresses = []

          CSV.foreach(file_path, headers: options.fetch(:headers, true), header_converters: :symbol ) do |row|
            addresses << Models::SmartyAddress.new({
                                       street: row[:street]&.strip,
                                       city: row[:city]&.strip,
                                       state: row[:state]&.strip,
                                       zipcode: row[:zip_code]&.strip,
                                     })
          end unless file_path.nil?

          addresses
        rescue Errno::ENOENT, NoFilePathProvidedError, Errno::EISDIR
          print_file_not_found file_path
          []
        end
      end

      private
      def self.print_file_not_found(file_path)
        puts "File not found at: #{file_path.to_s}"
      end
    end
  end
end
