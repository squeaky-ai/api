# frozen_string_literal: true

module DudaService
  class Auth
    def initialize(
      sdk_url:,
      timestamp:,
      secure_sig:,
      site_name:,
      current_user_uuid:
    )
      @sdk_url = CGI.unescape(sdk_url)
      @timestamp = timestamp
      @secure_sig = CGI.unescape(secure_sig)
      @site_name = CGI.unescape(site_name)
      @current_user_uuid = current_user_uuid
    end

    def valid?
      return false unless all_params_present?
      return false unless timestamp_within_bounds?

      sig_data_to_verify == decryped_public_key
    end

    private

    attr_reader :sdk_url, :timestamp, :secure_sig, :site_name, :current_user_uuid

    def all_params_present?
      %i[sdk_url timestamp secure_sig site_name current_user_uuid].all? do |param|
        !send(param).nil?
      end
    end

    def timestamp_within_bounds?
      (Time.now.to_i * 1000) - timestamp <= 120.seconds
    end

    def sig_data_to_verify
      "#{site_name}:#{sdk_url}:#{timestamp}"
    end

    def duda_public_key
      "-----BEGIN PUBLIC KEY-----\n#{ENV.fetch('DUDA_PUBLIC_KEY')}\n-----END PUBLIC KEY-----"
    end

    def decryped_public_key
      public_key = OpenSSL::PKey::RSA.new(duda_public_key)
      public_key.public_decrypt(Base64.decode64(secure_sig))
    rescue OpenSSL::OpenSSLError => e
      Rails.logger.error("Failed to decrypt sig - #{e}")
      nil
    end
  end
end
