# frozen_string_literal: true

module Types
  module Common
    class FiltersStatus < Types::BaseEnum
      value 'New', 'Show only new recordings'
      value 'Viewed', 'Show only viewed recordings'
    end
  end
end
