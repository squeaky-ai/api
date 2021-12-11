# frozen_string_literal: true

# Build the elasticsearch query object based on the
# site_id and filters that come from GraphQL
class RecordingsQuery
  def initialize(site_id, filters)
    @filters = filters
    @site_id = site_id

    @params = { bool: { must: [], must_not: [] } }
  end

  def build
    # site_id is absolutely needed!
    @params[:bool][:must] = [{ term: { site_id: { value: @site_id } } }]

    @filters.each do |k, v|
      method = "filter_by_#{k}"
      send(method, v) if respond_to?(method, true)
    end

    @params
  end

  private

  def filter_by_status(value)
    return if value.nil?

    viewed_recording_ids = Site.find(@site_id).recordings.select(:id).where(viewed: true).map(&:id)
    filter = { terms: { id: viewed_recording_ids } }

    filter_type = value == 'New' ? :must_not : :must

    @params[:bool][filter_type].push(filter) unless value.empty?
  end

  def filter_by_date(value)
    return unless value[:range_type]

    return filter_by_between_dates(value) if value[:range_type] == 'Between'

    return filter_by_before_dates(value) if value[:from_type] == 'Before'

    return filter_by_after_dates(value) if value[:from_type] == 'After'
  end

  def filter_by_duration(value)
    return unless value[:range_type]

    return filter_by_between_durations(value) if value[:range_type] == 'Between'

    return filter_by_greater_than_duration(value) if value[:from_type] == 'GreaterThan'

    return filter_by_less_than_duration(value) if value[:from_type] == 'LessThan'
  end

  def filter_by_start_url(value)
    filter = { term: { 'start_page.keyword': value } }
    @params[:bool][:must].push(filter) unless value.nil?
  end

  def filter_by_exit_url(value)
    filter = { term: { 'exit_page.keyword': value } }
    @params[:bool][:must].push(filter) unless value.nil?
  end

  def filter_by_visited_pages(value)
    filter = { terms: { 'page_views.keyword': value } }
    @params[:bool][:must].push(filter) unless value.empty?
  end

  def filter_by_unvisited_pages(value)
    filter = { terms: { 'page_views.keyword': value } }
    @params[:bool][:must_not].push(filter) unless value.empty?
  end

  def filter_by_devices(value)
    filter = { terms: { 'device.device_type.keyword': value } }
    @params[:bool][:must].push(filter) unless value.empty?
  end

  def filter_by_browsers(value)
    filter = { terms: { 'device.browser_name.keyword': value } }
    @params[:bool][:must].push(filter) unless value.empty?
  end

  def filter_by_viewport(value)
    filter_device_size(value, :min_width, :max_width, 'device_x')
    filter_device_size(value, :min_height, :max_height, 'device_y')
  end

  def filter_by_languages(value)
    filter = { terms: { 'language.keyword': value } }
    @params[:bool][:must].push(filter) unless value.empty?
  end

  def filter_device_size(value, min, max, key)
    filter = { range: { "device.#{key}" => {} } }
    filter[:range]["device.#{key}"][:gte] = value[min] if value[min]
    filter[:range]["device.#{key}"][:lte] = value[max] if value[max]
    @params[:bool][:must].push(filter)
  end

  def filter_ranges(key, from, to)
    filter = { range: {} }
    filter[:range][key] = {}
    filter[:range][key][:gte] = from if from
    filter[:range][key][:lte] = to if to
    @params[:bool][:must].push(filter)
  end

  def filter_by_between_dates(value)
    filter_ranges(:date_time, format_date(value[:between_from_date]), format_date(value[:between_to_date]))
  end

  def filter_by_before_dates(value)
    filter_ranges(:date_time, nil, format_date(value[:from_date]))
  end

  def filter_by_after_dates(value)
    filter_ranges(:date_time, format_date(value[:from_date]), nil)
  end

  def filter_by_between_durations(value)
    filter_ranges(:duration, value[:between_from_duration], value[:between_to_duration])
  end

  def filter_by_greater_than_duration(value)
    filter_ranges(:duration, value[:from_duration], nil)
  end

  def filter_by_less_than_duration(value)
    filter_ranges(:duration, nil, value[:from_duration])
  end

  def format_date(string)
    string.split('/').reverse.join('-')
  end
end
