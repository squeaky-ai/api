# frozen_string_literal: true

module Types
  module Feedback
    class NpsResponseItem < Types::BaseObject
      graphql_name 'FeedbackNpsResponseItem'

      field :id, ID, null: false
      field :score, Integer, null: false
      field :comment, String, null: true
      field :contact, Boolean, null: false
      field :email, String, null: true
      field :visitor, Types::Visitors::Visitor, null: false
      field :device, Types::Recordings::Device, null: false
      field :session_id, String, null: false
      field :recording_id, String, null: false
      field :timestamp, String, null: false
    end
  end
end
