# frozen_string_literal: true

module Resolvers
  module Visitors
    class GetMany < Resolvers::Base
      type Types::Visitors::Visitors, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 25
      argument :sort, Types::Visitors::Sort, required: false, default_value: 'last_activity_at__desc'
      argument :filters, Types::Visitors::Filters, required: false, default_value: nil

      def resolve(page:, size:, sort:, filters:)
        visitors = Site
                   .find(object.id)
                   .visitors
                   .includes(:recordings)
                   .where(where(filters))
                   .order(order(sort))
                   .page(page)
                   .per(size)
                   .group(:id)

        {
          items: visitors,
          pagination: {
            page_size: size,
            total: visitors.total_count,
            sort: sort
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'first_viewed_at__asc' => 'MIN(connected_at) ASC',
          'first_viewed_at__desc' => 'MIN(connected_at) DESC',
          'last_activity_at__asc' => 'MAX(disconnected_at) ASC',
          'last_activity_at__desc' => 'MAX(disconnected_at) DESC'
        }
        sorts[sort]
      end

      def where(filters)
        query = <<-SQL
          LOWER(recordings.locale) IN (?)
        SQL

        # puts '@@@', filters.to_h

        # if filters.languages.any?
        #   out[:recordings] ||= {}
        #   out[:recordings][:locale] = filters.languages.map { |l| Locale.get_locale(l) }
        # end

        [query, 'en-gb']
      end
    end
  end
end
