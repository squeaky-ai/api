# frozen_string_literal: true

class Feedback < ApplicationRecord
  include ActiveModel::Serialization

  belongs_to :site

  self.table_name = 'feedback'
end
