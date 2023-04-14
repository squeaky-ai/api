# typed: false
# frozen_string_literal: true

# Preview all emails at http://localhost:4000/rails/mailers/product_updates
class ProductUpdatesPreview < ActionMailer::Preview
  def q2_2022
    user = User.first
    ProductUpdatesMailer.q2_2022(user)
  end

  def july_2022
    user = User.first
    ProductUpdatesMailer.july_2022(user)
  end

  def august_2022
    user = User.first
    ProductUpdatesMailer.august_2022(user)
  end

  def september_2022
    user = User.first
    ProductUpdatesMailer.september_2022(user)
  end

  def november_2022
    user = User.first
    ProductUpdatesMailer.november_2022(user)
  end

  def pricing_change_2023
    user = User.first
    ProductUpdatesMailer.pricing_change_2023(user)
  end

  def december_2022
    user = User.first
    ProductUpdatesMailer.december_2022(user)
  end

  def pricing_migration_complete
    user = User.first
    ProductUpdatesMailer.pricing_migration_complete(user)
  end

  def january_2023
    user = User.first
    ProductUpdatesMailer.january_2023(user)
  end

  def february_2023
    user = User.first
    ProductUpdatesMailer.february_2023(user)
  end

  def march_2023
    user = User.first
    ProductUpdatesMailer.march_2023(user)
  end
end
