# frozen_string_literal: true

class VisitorsController < ApplicationController
  include PublicApiAuth

  def create
    # All of these field are required
    return render json: { error: params_error }, status: 400 if params_error
    # The site has ingest disabled and we shouldn't allow it in
    return render json: { error: 'Unauthorized' }, status: 401 unless ingest_enabled?
    # Visitor already exists with this user id
    return render json: { error: 'Visitor already exists' }, status: 409 if visitor_exists?

    create_visitor!

    render json: { status: 'OK' }, status: 201
  end

  private

  def create_visitor_params
    params.permit(:user_id, :data)
  end

  def params_error
    return 'user_id is required' unless create_visitor_params['user_id']
    return 'data is required' unless create_visitor_params['data']

    nil
  end

  def ingest_enabled?
    site.ingest_enabled && site.plan.features_enabled.include?('event_tracking')
  end

  def visitor_exists?
    !Visitor.find_by_external_id(site.id, create_visitor_params['user_id'].to_s).nil?
  end

  def create_visitor!
    Visitor.create(
      site_id: site.id,
      visitor_id: SecureRandom.base36[0, 10],
      source: Visitor::API,
      external_attributes:
    )
  end

  def external_attributes
    out = {
      id: create_visitor_params['user_id'].to_s
    }

    JSON.parse(create_visitor_params['data']).each do |key, value|
      out[key] = value.to_s
    end

    out
  end
end
