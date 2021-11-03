# frozen_string_literal: true

# A map between page urls and screenshots stored in S3
class Screenshot < ApplicationRecord
  belongs_to :site
end
