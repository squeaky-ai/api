# frozen_string_literal: true

class Billing < ApplicationRecord
  belongs_to :site
  belongs_to :user

  has_many :transactions

  self.table_name = 'billing'
end
