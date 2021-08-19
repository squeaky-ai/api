# frozen_string_literal: true

# Visitors on sites
class Visitor < ApplicationRecord
  has_many :recordings
end
