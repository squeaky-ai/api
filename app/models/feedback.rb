# frozen_string_literal: true

# The settings for collecting site feedback
class Feedback < ApplicationRecord
  belongs_to :site

  self.table_name = 'feedback'
end
