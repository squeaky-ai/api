# frozen_string_literal: true

class Changelog < ApplicationRecord
  include Authorable

  self.table_name = 'changelog'

  def self.find_by_slug(slug)
    find_by('LOWER(slug) = ?', slug)
  end
end
