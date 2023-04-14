# typed: false
# frozen_string_literal: true

class ProviderAuth < ApplicationRecord
  belongs_to :site

  self.table_name = 'provider_auth'

  def provider_app_uuid
    case provider
    when 'duda'
      Duda::Client.app_uuid
    end
  end

  def refresh_token!
    case provider
    when 'duda'
      refresh_duda_token!
    end
  end

  private

  def refresh_duda_token!
    response = Duda::Client.new(api_endpoint:).refresh_access_token(refresh_token:)

    update(
      expires_at: response['expiration_date'],
      access_token: response['authorization_code']
    )
  end
end
