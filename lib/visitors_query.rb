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

  def site
    @site ||= Site.find(@site_id)
  end

  def filter_by_status(value)
    return if value.nil?

    viewed_ids = site.recordings.select(:visitor_id).where(viewed: true).map(&:visitor_id)
    filter = { terms: { id: viewed_ids } }

    filter_type = value == 'New' ? :must : :must_not

    @params[:bool][filter_type].push(filter) unless value.empty?
  end

  def filter_by_recordings(value)
    return if value[:count].nil?

    recording_ids = recording_ids_by_count(value)

    @params[:bool][:must].push(terms: { id: recording_ids.map(&:id) }) unless value.empty?
  end

  def filter_by_first_visited(value)
    return unless value[:range_type]

    return filter_by_between_first_visited(value) if value[:range_type] == 'Between'

    return filter_by_before_first_viewed(value) if value[:from_type] == 'Before'

    return filter_by_after_first_viewed(value) if value[:from_type] == 'After'
  end

  def filter_by_last_activity(value)
    return unless value[:range_type]

    return filter_by_between_last_activity(value) if value[:range_type] == 'Between'

    return filter_by_before_last_activity(value) if value[:from_type] == 'Before'

    return filter_by_after_last_activity(value) if value[:from_type] == 'After'
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

  def filter_by_between_first_visited(value)
    filter_ranges(:first_viewed_at, format_date(value[:between_from_date]), format_date(value[:between_to_date]))
  end

  def filter_by_before_first_viewed(value)
    filter_ranges(:first_viewed_at, nil, format_date(value[:from_date]))
  end

  def filter_by_after_first_viewed(value)
    filter_ranges(:first_viewed_at, format_date(value[:from_date]), nil)
  end

  def filter_by_between_last_activity(value)
    filter_ranges(:last_activity_at, format_date(value[:between_from_date]), format_date(value[:between_to_date]))
  end

  def filter_by_before_last_activity(value)
    filter_ranges(:last_activity_at, nil, format_date(value[:from_date]))
  end

  def filter_by_after_last_activity(value)
    filter_ranges(:last_activity_at, format_date(value[:from_date]), nil)
  end

  def recording_ids_by_count(value)
    counts = site
             .visitors
             .select('visitors.id, COUNT(recordings) rec_count')
             .where('recordings.deleted = false')
             .group('visitors.id')

    counts.filter do |c|
      value[:range_type] == 'GreaterThan' ? c.rec_count > value[:count] : c.rec_count < value[:count]
    end
  end

  def format_date(string)
    string.split('/').reverse.join('-')
  end
end
