# frozen_string_literal: true

module Types
  # The 'notes' field on the site is handled here as
  # we only want to load the data if it is requested
  class NotesExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 25, description: 'The page size')
    end

    def resolve(object:, arguments:, **_rest)
      notes = Site
              .find(object.object['id'])
              .notes
              .order('created_at DESC')
              .page(arguments[:page])
              .per(arguments[:size])

      {
        items: notes,
        pagination: pagination(notes, arguments[:size])
      }
    end

    private

    def pagination(notes, size)
      {
        page_size: size,
        total: notes.total_count
      }
    end
  end
end
