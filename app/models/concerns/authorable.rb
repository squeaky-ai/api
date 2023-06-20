# frozen_string_literal: true

module Authorable
  extend ActiveSupport::Concern

  included do
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
end
