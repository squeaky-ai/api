# frozen_string_literal: true

class Blog < ApplicationRecord
  include Authorable

  self.table_name = 'blog'

  def self.find_by_slug(slug)
    find_by('LOWER(slug) = ?', slug)
  end

  def self.categories
    select('DISTINCT(category)').map(&:category)
  end

  def self.tags
    select('DISTINCT(UNNEST(tags)) tag').map(&:tag)
  end
end
