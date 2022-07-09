# frozen_string_literal: true

# Preview all emails at http://localhost:4000/rails/mailers/product_updates
class ProductUpdatesPreview < ActionMailer::Preview
  def q2_2022
    user = User.first
    ProductUpdatesMailer.q2_2022(user)
  end
end
