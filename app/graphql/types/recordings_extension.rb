# frozen_string_literal: true

module Types
  # The 'recordings' field on the site is handled here as
  # we only want to load the data if it is requested
  class RecordingsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 15, description: 'The page size')
      field.argument(:query, String, required: false, default_value: '', description: 'The search query')
      field.argument(:sort, SortType, required: false, default_value: 'DESC', description: 'The sort order')
    end

    def resolve(object:, arguments:, **_rest)
      recordings = Recording
                   .where(site_id: object.object['id'])
                   .page(arguments[:page])
                   .per(arguments[:size])
                   .order(connected_at: arguments[:sort].downcase.to_sym)

      # TODO: Search

      {
        items: recordings,
        pagination: pagination(arguments, recordings, arguments[:size])
      }
    end

    def pagination(arguments, recordings, size)
      {
        page_size: size,
        page_count: recordings.total_pages,
        sort: arguments[:sort]
      }
    end
  end
end
