# frozen_string_literal: true

# Visitors on sites that have recordings
class Visitor < ApplicationRecord
  has_many :recordings
  has_many :pages, through: :recordings

  def language
    Locale.get_language(recordings.first.locale)
  end

  def devices
    recordings.map(&:device)
  end

  def attributes
    return nil if external_attributes.empty?

    external_attributes.to_json
  end

  def viewed
    recordings.where(viewed: true).size.positive?
  end

  def first_viewed_at
    recordings.order(created_at: :desc).first.created_at
  end

  def last_activity_at
    recordings.order(created_at: :desc).last.created_at
  end

  def recordings_count
    {
      total: recordings.where(deleted: false).size,
      new: recordings.where(deleted: false, viewed: false).size
    }
  end

  def page_views_count
    {
      total: pages.size,
      unique: recordings.joins(:pages).select(:pages).uniq.count
    }
  end
end
