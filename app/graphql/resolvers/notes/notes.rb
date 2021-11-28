# frozen_string_literal: true

module Resolvers
  module Notes
    class Notes < Resolvers::Base
      type Types::Notes::Notes, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 25

      def resolve(page:, size:)
        notes = Site
                .find(object.id)
                .notes
                .order('created_at DESC')
                .page(page)
                .per(size)

        {
          items: notes,
          pagination: {
            page_size: size,
            total: notes.total_count
          }
        }
      end
    end
  end
end