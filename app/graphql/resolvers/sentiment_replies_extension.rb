# frozen_string_literal: true

module Types
  # The sentiment replies items
  class SentimentRepliesExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      results = Sentiment
                .joins(:recording)
                .where('recordings.site_id = ? AND sentiments.created_at::date >= ? AND sentiments.created_at::date <= ?', site_id, from_date, to_date)
                .select('sentiments.score')

      {
        total: results.size,
        responses: results
      }
    end
  end
end
