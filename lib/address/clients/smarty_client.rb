# frozen_string_literal: true

require "json"
require "address/models/address"
require "address/models/smarty_address"
require "net/http"
require "uri"

module Clients
  ##
  # This client handles sending the validation request to Smarty
  # some of the responsibilities are building the appropriate request body
  # and sending the necessary http request with necessary auth and headers
  class SmartyClient
    STREET_ADDRESS_URI = "https://us-street.api.smarty.com/street-address?"
    HEADERS = { "Content-Type" => "application/json", "charset" => "utf-8" }.freeze
    CANDIDATES = 1

    def validate_addresses(addresses)
      return if addresses.empty?

      http_response = http.request(request(addresses))
      if http_response.code == "200"
        handle_success(addresses, http_response)
      else
        puts "Something went wrong."
        puts "status: #{http_response.code}, error: #{http_response.body}"
        []
      end
    end

    private

    def handle_success(addresses, http_response)
      addresses.each do |address|
        address.validation_sent = true
        validated_result = parsed_response(http_response.body).select do |validation|
          validation[:input_id] == address.key
        end.first
        address.validated_address = build_address(validated_result) unless validated_result.nil?
      end
    end

    def parsed_response(body)
      @parsed_response ||= JSON.parse(body, symbolize_names: true)
    end

    def build_address(object)
      Models::Address.new({
                            # disabling rubocop because delivery_line_1 needs to match the API response
                            street: object[:delivery_line_1], # rubocop:disable Naming/VariableNumber
                            city: object.dig(:components, :city_name),
                            state: object.dig(:components, :state_abbreviation),
                            zipcode: object.dig(:components, :zipcode),
                            plus4_code: object.dig(:components, :plus4_code)
                          })
    end

    def request(addresses)
      request = Net::HTTP::Post.new(uri.request_uri, HEADERS)
      request.body = addresses.map do |address|
        address.to_hash.merge({ input_id: address.key, candidates: CANDIDATES }) if address.valid?
      end.compact.to_json
      request
    end

    def http
      http = Net::HTTP.new(uri.host || "", uri.port)
      http.use_ssl = true
      http
    end

    def uri
      URI(url_string)
    end

    def url_string
      @url_string ||= STREET_ADDRESS_URI + "auth-id=#{ENV["AUTH_ID"]}&"\
        "auth-token=#{ENV["AUTH_TOKEN"]}"\
        "&license=#{ENV["LICENSE_TYPE"]}"
    end
  end
end
