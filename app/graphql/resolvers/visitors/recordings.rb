# frozen_string_literal: true

module Resolvers
  module Visitors
    class Recordings < Resolvers::Base
      type 'Types::Recordings::Recordings', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Recordings::Sort, required: false, default_value: 'connected_at__desc'
      argument :exclude_recording_ids, [ID], required: false, default_value: []

      def resolve(page:, size:, sort:, exclude_recording_ids:)
        recordings = Recording
          .where('status = ? AND visitor_id = ?', Recording::ACTIVE, object.id)
          .includes(:pages, :visitor)
          .order(order(sort))

        recordings = recordings.where.not(id: exclude_recording_ids) unless exclude_recording_ids.empty?
        recordings = recordings.page(page).per(size)

        {
          items: recordings,
          pagination: {
            page_size: size,
            total: recordings.total_count,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'connected_at__asc' => 'connected_at ASC',
          'connected_at__desc' => 'connected_at DESC',
          'duration__asc' => Arel.sql('(disconnected_at - connected_at) ASC'),
          'duration__desc' => Arel.sql('(disconnected_at - connected_at) DESC'),
          'page_count__asc' => 'pages_count ASC',
          'page_count__desc' => 'pages_count DESC'
        }
        sorts[sort]
      end
    end
  end
end
