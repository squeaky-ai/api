# frozen_string_literal: true

class EventsController < ApplicationController
  include PublicApiAuth

  def create
    # All of these field are required
    return render json: { error: params_error }, status: :bad_request if params_error
    # The site has ingest disabled and we shouldn't allow it in
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless ingest_enabled?

    create_event!

    render json: { status: 'OK' }, status: :created
  end

  private

  def create_event_params
    params.permit(:name, :user_id, :data, :timestamp)
  end

  def params_error
    return 'name is required' unless create_event_params['name']
    return 'data is required' unless create_event_params['data']
    return "timestamp should be a millisecond precision unix integer, e.g. #{current_unix_timestamp_ms}" unless valid_unix_timestamp?

    nil
  end

  def valid_unix_timestamp?
    return true unless create_event_params['timestamp']

    create_event_params['timestamp'].to_i > site.created_at.to_i * 1000
  end

  def event
    {
      name: create_event_params['name'],
      data: JSON.parse(create_event_params['data']),
      timestamp: create_event_params['timestamp']&.to_i || current_unix_timestamp_ms,
      site_id: site.id,
      visitor_id: visitor&.id
    }
  end

  def current_unix_timestamp_ms
    Time.now.to_i * 1000
  end

  def create_event!
    ClickHouse::CustomEvent.create_from_api(event)
    EventCapture.create_names_for_site!(site, [event[:name]], EventCapture::API)
  end

  def ingest_enabled?
    site.ingest_enabled && site.plan.features_enabled.include?('event_tracking')
  end

  def visitor
    return unless create_event_params['user_id']

    @visitor ||= Visitor.find_by_external_id(site.id, create_event_params['user_id'])
  end
end
