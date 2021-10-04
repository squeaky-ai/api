# frozen_string_literal: true

# Build the elasticsearch query object based on the
# site_id and filters that come from GraphQL
class VisitorsQuery
  def initialize(site_id, search, filters)
    @search = search
    @filters = filters
    @site_id = site_id

    @params = { bool: { must: [], must_not: [] } }
  end

  def build
    # site_id is absolutely needed!
    @params[:bool][:must] = [{ term: { site_id: { value: @site_id } } }]
    # Filter on the rest of the results if one is provided
    @params[:bool][:filter] = [{ query_string: { query: "*#{@search}*" } }] unless @search.empty?

    @filters.each do |k, v|
      method = "filter_by_#{k}"
      send(method, v) if respond_to?(method, true)
    end

    @params
  end

  private

  def filter_by_first_visited(value)
    if value[:range_type] == 'Between'
      return filter_ranges(:first_viewed_at, format_date(value[:between_from_date]), format_date(value[:between_to_date]))
    end

    if value[:range_type] == 'From' && value[:from_type] == 'Before'
      return filter_ranges(:first_viewed_at, nil, format_date(value[:from_date]))
    end

    if value[:range_type] == 'From' && value[:from_type] == 'After'
      return filter_ranges(:first_viewed_at, format_date(value[:from_date]), nil)
    end
  end

  def filter_by_last_activity(value)
    if value[:range_type] == 'Between'
      return filter_ranges(:last_activity_at, format_date(value[:between_from_date]), format_date(value[:between_to_date]))
    end

    if value[:range_type] == 'From' && value[:from_type] == 'Before'
      return filter_ranges(:last_activity_at, nil, format_date(value[:from_date]))
    end

    if value[:range_type] == 'From' && value[:from_type] == 'After'
      return filter_ranges(:last_activity_at, format_date(value[:from_date]), nil)
    end
  end

  def filter_by_languages(value)
    filter = { terms: { 'language.keyword': value } }
    @params[:bool][:must].push(filter) unless value.empty?
  end

  def filter_ranges(key, from, to)
    filter = { range: {} }
    filter[:range][key] = {}
    filter[:range][key][:gte] = from if from
    filter[:range][key][:lte] = to if to
    @params[:bool][:must].push(filter)
  end

  def format_date(string)
    string.split('/').reverse.join('-')
  end
end
