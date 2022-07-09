# frozen_string_literal: true

class ProductUpdatesMailer < ApplicationMailer
  def q2_2022(user) # rubocop:disable Naming/VariableNumber
    @user = user

    return unless user.communication_enabled?(:product_updates_email)

    mail(to: user.email, subject: 'Product Update: Q2 2022.')
  end
end
