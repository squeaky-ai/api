# frozen_string_literal: true

# Build the elasticsearch query object based on the
# site_id and filters that come from GraphQL
class RecordingsQuery
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

  def filter_by_date(value)
    puts '@@ date', value
  end

  def filter_by_duration(value)
    is_from_only = value[:duration_range_type] == 'From'

    from = is_from_only ? value[:from_duration] : value[:between_from_duration]
    to = is_from_only ? nil : value[:between_to_duration]

    return if from.nil? && to.nil?

    filter_durations(from, to)
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
    filter_viewports(value, :min_width, :max_width, 'viewport_x')
    filter_viewports(value, :min_height, :max_height, 'viewport_y')
  end

  def filter_by_languages(value)
    filter = { terms: { 'language.keyword': value } }
    @params[:bool][:must].push(filter) unless value.empty?
  end

  def filter_viewports(value, min, max, key)
    filter = { range: { "device.#{key}" => {} } }
    filter[:range]["device.#{key}"][:gte] = value[min] if value[min]
    filter[:range]["device.#{key}"][:lte] = value[max] if value[max]
    @params[:bool][:must].push(filter)
  end

  def filter_durations(from, to)
    filter = { range: { duration: {} } }
    filter[:range][:duration][:gte] = from if from
    filter[:range][:duration][:lte] = to if to
    @params[:bool][:must].push(filter)
  end
end
