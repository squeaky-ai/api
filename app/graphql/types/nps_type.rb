# frozen_string_literal: true

module Types
  class NpsType < Types::BaseObject
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
  end
end
