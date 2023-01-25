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
      @secure_sig = secure_sig
      @site_name = CGI.unescape(site_name)
      @current_user_uuid = current_user_uuid
    end

    def valid?
      return false unless all_params_present?
      return false unless timestamp_within_bounds?

      signature_valid?
    end

    def fetch_user
      # If the user is the account owner then this is the easiest
      # way to fetch the user
      user = ::User.find_by(provider_uuid: current_user_uuid)
      return user if user

      # If the user is not the account owner, then they will have
      # a different current_user_uuid which will differ from that
      # of the account holder, but will share the same email. We
      # can't have multiple accounts with the same user, so everyone
      # will assume the same user for now
      site = ::Site.find_by!(uuid: site_name)
      site.users.first
    end

    private

    attr_reader :sdk_url, :timestamp, :secure_sig, :site_name, :current_user_uuid

    def all_params_present?
      all_present = %i[sdk_url timestamp secure_sig site_name current_user_uuid].all? do |param|
        !send(param).nil?
      end

      Rails.logger.warn('Not all params are present') unless all_present

      all_present
    end

    def timestamp_within_bounds?
      now = Time.now.to_i * 1000
      within_bounds = now - timestamp <= max_timestamp_difference_ms

      Rails.logger.warn("Timestamp not within bounds: #{now} - #{timestamp}") unless within_bounds

      within_bounds
    end

    def signature_valid?
      valid = sig_data_to_verify == decryped_public_key

      Rails.logger.warn("Signature is not valid: #{sig_data_to_verify} != #{decryped_public_key}") unless valid

      valid
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

    def max_timestamp_difference_ms
      120.seconds * 1000
    end
  end
end
