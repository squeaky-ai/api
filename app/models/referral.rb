# frozen_string_literal: true

class Referral < ApplicationRecord
  belongs_to :partner, optional: true
  belongs_to :site, optional: true
end
