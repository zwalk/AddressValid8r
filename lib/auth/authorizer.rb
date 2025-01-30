# frozen_string_literal: true

require "io/console"

## Authorizer
# sets the auth values that are necessary to run validation through Smarty
class Authorizer
  REQUIRED_ENV_VALUES = %w[AUTH_ID AUTH_TOKEN LICENSE_TYPE].freeze
  ENV_FILE_PATH = ".env"
  WRITE = "w"
  APPEND = "a"
  class << self
    def authorize
      REQUIRED_ENV_VALUES.each do |env_key|
        next unless ENV[env_key].nil? || ENV[env_key].empty?

        puts "Enter your #{env_key.gsub("_", " ").capitalize}:"
        value = $stdin.noecho(&:gets).chomp
        write_to_env_file(env_key, value)
      end
    end

    def reset
      File.open(ENV_FILE_PATH, WRITE) do |file|
        file.truncate(0)
      end
      ENV.clear
    end

    private

    def write_to_env_file(key, value)
      File.open(ENV_FILE_PATH, APPEND) do |file|
        file.puts "#{key}=#{value}"
      end
    end
  end
end
