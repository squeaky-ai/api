# frozen_string_literal: true

module Types
  # The paginated nps response items
  class NpsResponseExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 10, description: 'The page size')
      field.argument(:sort, NpsResponseSortType, required: false, default_value: 'timestamp__desc', description: 'Sort order')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Nps
                .joins(recording: :visitor)
                .where('recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?', site_id, from_date, to_date)
                .select('nps.*, recordings.session_id, visitors.id visitor_id, visitors.visitor_id visitor_visitor_id')
                .order(sort_by(arguments))
                .page(arguments[:page])
                .per(arguments[:size])

      {
        items: map_results(results),
        pagination: {
          page_size: arguments[:size],
          total: results.total_count,
          sort: arguments[:sort]
        }
      }
    end

    private

    def sort_by(arguments)
      case arguments[:sort]
      when 'timestamp__desc'
        'created_at DESC'
      when 'timestamp__asc'
        'created_at ASC'
      end
    end

    def map_results(results)
      results.map do |r|
        {
          id: r.id,
          score: r.score,
          contact: r.contact,
          comment: r.comment,
          session_id: r.session_id,
          recording_id: r.recording_id,
          timestamp: r.created_at.utc.iso8601,
          visitor: {
            id: r.visitor_id,
            visitor_id: r.visitor_visitor_id
          }
        }
      end
    end
  end
end
