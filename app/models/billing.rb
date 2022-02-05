# frozen_string_literal: true

class Billing < ApplicationRecord
  belongs_to :site
  belongs_to :user

  self.table_name = 'billing'
end
