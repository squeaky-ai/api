# frozen_string_literal: true

class ProviderAuth < ApplicationRecord
  belongs_to :site

  self.table_name = 'provider_auth'
end
