# frozen_string_literal: true

class Billing < ApplicationRecord
  belongs_to :site
  belongs_to :user

  has_many :transactions, dependent: :destroy

  after_destroy :destroy_stripe_customer!

  self.table_name = 'billing'

  def destroy_stripe_customer!
    StripeService.delete_customer(customer_id) if customer_id
  end
end
