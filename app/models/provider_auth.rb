# frozen_string_literal: true

class ProviderAuth < ApplicationRecord
  belongs_to :site

  self.table_name = 'provider_auth'

  def provider_app_uuid
    case site.provider
    when 'duda'
      ENV.fetch('DUDA_APP_UUID')
    end
  end
end
