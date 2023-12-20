# frozen_string_literal: true

class ProductUpdatesMailer < ApplicationMailer
  def q2_2022(user)
    @user = user
    @unsubscribable = true

    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: Q2 2022')
  end

  def july_2022(user)
    @user = user
    @unsubscribable = true

    return if user.sites.empty?
    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: July 2022')
  end

  def august_2022(user)
    @user = user
    @unsubscribable = true

    return if user.sites.empty?
    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: August 2022')
  end

  def september_2022(user)
    @user = user
    @unsubscribable = true

    return if user.sites.empty?
    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: September-October 2022')
  end

  def november_2022(user)
    @user = user
    @unsubscribable = true

    return if user.sites.empty?
    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: November 2022')
  end

  def pricing_change_2023(user)
    @user = user
    @unsubscribable = false

    mail(to: user.email, subject: 'Important: New Squeaky Pricing 2023')
  end

  def december_2022(user)
    @user = user
    @unsubscribable = true

    return if user.sites.empty?
    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: December 2022')
  end

  def pricing_migration_complete(user)
    @user = user
    @unsubscribable = false

    mail(to: user.email, subject: 'Migration complete ✅')
  end

  def january_2023(user)
    @user = user
    @unsubscribable = true

    return if user.sites.empty?
    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: January 2023')
  end

  def february_2023(user)
    @user = user
    @unsubscribable = true

    return if user.sites.empty?
    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: February 2023')
  end

  def march_2023(user)
    @user = user
    @unsubscribable = true

    return if user.sites.empty?
    return unless user.communication_enabled?(:product_updates_email)
    return if user.first_name.blank?

    mail(to: user.email, subject: 'Product Update: March 2023')
  end

  def free_plan_changes_2023(user)
    @user = user
    @unsubscribable = false

    mail(to: user.email, subject: 'Upcoming changes')
  end
end
