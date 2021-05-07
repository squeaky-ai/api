# frozen_string_literal: true

# Encode and decode JWTs using the secret key stored in the
# Rails config. TODO: We should include the issuer to make
# sure tokens can't be shared between environments
class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def self.encode(payload, exp = 1.month.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')
    HashWithIndifferentAccess.new decoded.first
  end
end
