# frozen_string_literal: true

module Models
  class SmartyAddress < Address
    INVALID_ADDRESS = "Invalid Address"
    NOT_PROCESSED = "Not Processed"
    module MaxLength
      STREET = 100
      CITY = 64
      STATE = 32
      ZIPCODE = 16
    end

    attr_accessor :validated_address,
                  :validation_sent

    def initialize(attrs = {})
      @validation_sent = false
      super(attrs)
    end

    ## Smarty Requirements
    # street + city + state OR
    # street + zipcode OR
    # street (freeform = entire address in one line)
    # -
    # For the purposes of this work sample, I have chosen to simply enforce
    # that street is present since Smarty supports freeform submission in that field
    # all length requirements are from the smarty docs @
    # https://www.smarty.com/docs/cloud/us-street-api#http-response-status
    def valid?
      !@street.nil? &&
        !@street.empty? &&
        @street.length <= MaxLength::STREET &&
        nil_safe_length(@city) <= MaxLength::CITY &&
        nil_safe_length(@state) <= MaxLength::STATE &&
        nil_safe_length(@zipcode) <= MaxLength::ZIPCODE
    end

    def to_cli_format
      "#{@street}, #{@city}, #{@zipcode} -> #{cli_format_validated_address}"
    end

    private

    def cli_format_validated_address
      if @validated_address.nil? && @validation_sent
        INVALID_ADDRESS
      elsif @validated_address.nil?
        NOT_PROCESSED
      else
        "#{@validated_address.street}, #{@validated_address.city}, "\
          "#{@validated_address.zipcode}-#{validated_address.plus4_code}"
      end
    end

    def nil_safe_length(arg)
      return 0 if arg.nil?

      arg.to_s.length
    end
  end
end
