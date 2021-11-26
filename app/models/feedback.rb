# frozen_string_literal: true

class Feedback < ApplicationRecord
  belongs_to :site

  self.table_name = 'feedback'
end
