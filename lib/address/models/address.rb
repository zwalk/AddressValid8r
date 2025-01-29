# frozen_string_literal: true

require "securerandom"

module Models
  ## Address
  # basic address data structure of a US Address
  class Address
    attr_reader :street,
                :city,
                :state,
                :zipcode,
                :key,
                :plus4_code

    def initialize(attributes = {})
      @key = SecureRandom.uuid
      @street = attributes[:street]
      @city = attributes[:city]
      @state = attributes[:state]
      @zipcode = attributes[:zipcode]
      @plus4_code = attributes[:plus4_code]
    end

    def to_hash
      {
        key: @key,
        street: @street || "",
        city: @city || "",
        state: @state || "",
        zipcode: @zipcode || "",
        plus4_code: @plus4_code || ""
      }
    end

    def ==(other)
      other.class == self.class &&
        other.street == street &&
        other.city == city &&
        other.state == state &&
        other.zipcode == zipcode &&
        other.plus4_code == plus4_code
    end
  end
end
