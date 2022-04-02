# frozen_string_literal: true

class Blog < ApplicationRecord
  self.table_name = 'blog'

  def author
    case self[:author]
    when 'lewis'
      {
        name: 'Lewis Monteith',
        image: 'https://cdn.squeaky.ai/blog/lewis.jpg'
      }
    when 'chris'
      {
        name: 'Chris Pattison',
        image: 'https://cdn.squeaky.ai/blog/chris.jpg'
      }
    end
  end

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
