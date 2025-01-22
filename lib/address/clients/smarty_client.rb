# frozen_string_literal: true

require 'json'
require 'address/models/address'
require 'address/models/smarty_address'
require 'net/http'
require 'uri'

module Clients
  class SmartyClient
    STREET_ADDRESS_URI = 'https://us-street.api.smarty.com/street-address?'
    HEADERS = { 'Content-Type' => 'application/json', 'charset' => 'utf-8' }
    CANDIDATES = 1

    def self.validate_addresses(addresses)
      unless addresses.empty?
        http_response = http.request(request(addresses))
        parsed_response = JSON.parse(http_response.body, symbolize_names: true)
        addresses.each do |address|
          address.validation_sent = true
          validated_result = parsed_response.select { |validation| validation.dig(:input_id) == address.key}.first
          address.validated_address = build_address(validated_result) unless validated_result.nil?
        end
      end
    end

    private

    def self.build_address(object)
      Models::Address.new({
                            street: object.dig(:delivery_line_1),
                            city: object.dig(:components, :city_name),
                            state: object.dig(:components, :state_abbreviation),
                            zipcode: object.dig(:components, :zipcode),
                            plus4_code: object.dig(:components, :plus4_code),
                          })
    end

    def self.request(addresses)
      request = Net::HTTP::Post.new(uri.request_uri, HEADERS)
      request.body = addresses.map do |address|
        address.to_hash.merge({input_id: address.key, candidates: CANDIDATES}) if address.valid?
      end.compact.to_json
      request
    end

    def self.http
      http = Net::HTTP.new(uri.host || '', uri.port)
      http.use_ssl = true
      http
    end

    def self.uri
      URI(url_string)
    end

    def self.url_string
      @url_string ||= STREET_ADDRESS_URI + "auth-id=#{ENV["AUTH_ID"]}&"\
                            "auth-token=#{ENV["AUTH_TOKEN"]}"\
                            "&license=#{ENV['LICENSE_TYPE']}"
    end

  end
end
