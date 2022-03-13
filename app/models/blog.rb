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
end
