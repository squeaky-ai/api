# frozen_string_literal: true

class AdTrackingService
  def initialize(utm_content_ids:, sort:, from_date:, to_date:, page: nil, size: nil) # rubocop:disable Metrics/ParameterLists
    @utm_content_ids = utm_content_ids
    @sort = sort
    @from_date = from_date
    @to_date = to_date
    @page = page
    @size = size
  end

  def results
    sql = <<-SQL
      SELECT *
      FROM (
        SELECT DISTINCT
          visitors.id visitor_id,
          visitors.visitor_id visitor_visitor_id,
          visitors.created_at visitor_created_at,
          users.id user_id,
          users.first_name user_first_name,
          users.last_name user_last_name,
          users.created_at user_created_at,
          sites.id site_id,
          sites.name site_name,
          sites.created_at site_created_at,
          sites.verified_at site_verified_at,
          plans.plan_id site_plan_id,
          recordings.utm_content utm_content,
          recordings.gad gad,
          recordings.gclid gclid
        FROM
          visitors
        INNER JOIN
          recordings ON recordings.visitor_id = visitors.id
        LEFT OUTER JOIN
          users ON users.id::text = visitors.external_attributes->>'id'::text
        LEFT OUTER JOIN
          teams ON teams.user_id = users.id
        LEFT OUTER JOIN
          sites ON sites.id = teams.site_id
        LEFT OUTER JOIN
          plans ON plans.site_id = sites.id
      ) results
      WHERE
        results.site_id = :site_id AND
        results.visitor_created_at::date BETWEEN :from_date AND :to_date AND
        #{content_query}
      ORDER BY #{order} NULLS LAST
        #{limit}
        #{offset}
    SQL

    variables = {
      site_id: Rails.application.config.squeaky_site_id,
      from_date:,
      to_date:
    }

    if paginated?
      variables[:limit] = size
      variables[:offset] = (size * (page - 1))
    end

    variables[:content_ids] = utm_content_ids unless utm_content_ids.empty?

    results = Sql.execute(sql, [variables])

    format_response(results)
  end

  def count
    sql = <<-SQL
      SELECT
        COUNT(*)
      FROM (
        SELECT
          sites.id site_id,
          visitors.created_at visitor_created_at,
          recordings.utm_content utm_content,
          recordings.gclid gclid
        FROM
          visitors
        INNER JOIN
          recordings ON recordings.visitor_id = visitors.id
        LEFT OUTER JOIN
          users ON users.id::text = visitors.external_attributes->>'id'::text
        LEFT OUTER JOIN
          teams ON teams.user_id = users.id
        LEFT OUTER JOIN
          sites ON sites.id = teams.site_id
        LEFT OUTER JOIN
          plans ON plans.site_id = sites.id
      ) results
      WHERE
        results.site_id = :site_id AND
        results.visitor_created_at::date BETWEEN :from_date AND :to_date AND
        #{content_query}
    SQL

    variables = {
      site_id: Rails.application.config.squeaky_site_id,
      from_date:,
      to_date:
    }

    variables[:utm_content] = utm_content_ids unless utm_content_ids.empty?

    Sql.execute(sql, [variables]).first['count']
  end

  private

  attr_reader :utm_content_ids, :sort, :from_date, :to_date, :page, :size

  def paginated?
    size && page
  end

  def format_response(ad_tracking)
    ad_tracking.map do |a|
      {
        visitor_id: a['visitor_id'],
        visitor_visitor_id: a['visitor_visitor_id'],
        visitor_created_at: a['visitor_created_at'],
        user_id: a['user_id'],
        user_name: "#{a['user_first_name']} #{a['user_last_name']}".strip.presence,
        user_created_at: a['user_created_at'],
        site_id: a['site_id'],
        site_name: a['site_name'],
        site_created_at: a['site_created_at'],
        site_verified_at: a['site_verified_at'],
        site_plan_name: Plans.name_for(plan_id: a['site_plan_id']),
        utm_content: a['utm_content']
      }
    end
  end

  def limit
    paginated? ? 'LIMIT :limit' : ''
  end

  def offset
    paginated? ? 'OFFSET :offset' : ''
  end

  def order
    sorts = {
      'user_created_at__asc' => 'results.user_created_at ASC',
      'user_created_at__desc' => 'results.user_created_at DESC',
      'site_created_at__asc' => 'results.site_created_at ASC',
      'site_created_at__desc' => 'results.site_created_at DESC',
      'site_verified_at__asc' => 'results.site_verified_at ASC',
      'site_verified_at__desc' => 'results.site_verified_at DESC'
    }
    sorts[sort]
  end

  def content_query
    return 'results.utm_content IS NOT null OR results.gclid IS NOT NULL' if utm_content_ids.empty?

    'results.utm_content IN (:utm_content)'
  end
end
