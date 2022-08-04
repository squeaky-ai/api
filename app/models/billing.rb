# frozen_string_literal: true

class Billing < ApplicationRecord
  belongs_to :site
  belongs_to :user

  has_many :transactions, dependent: :destroy

  after_destroy :destroy_stripe_customer!

  self.table_name = 'billing'

  # Latest bill was paid
  VALID = 'valid'
  # Latest bill was not paid
  INVALID = 'invalid'
  # Customer went through the onboarding flow
  # but we haven't recieved confirmation yet
  OPEN = 'open'
  # Customer attempted billing but bounced
  # and never completed
  NEW = 'new'

  def destroy_stripe_customer!
    StripeService::Billing.new(user, site).delete_customer(customer_id) if customer_id
  end
end
