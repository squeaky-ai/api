# frozen_string_literal: true

module Types
  module Nps
    class Nps < Types::BaseObject
      description 'The nps object'

      field :responses,
            NpsResponseType,
            null: false,
            extensions: [NpsResponseExtension]

      field :groups,
            NpsGroupsType,
            null: false,
            extensions: [NpsGroupsExtension]

      field :stats,
            NpsStatsType,
            null: false,
            extensions: [NpsStatsExtension]

      field :ratings,
            [NpsRatingType, { null: true }],
            null: false,
            extensions: [NpsRatingsExtension]

      field :replies,
            NpsRepliesType,
            null: false,
            extensions: [NpsRepliesExtension]

      field :scores,
            NpsScoresType,
            null: false,
            extensions: [NpsScoresExtension]
    end
  end
end
