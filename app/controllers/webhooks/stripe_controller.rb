# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    def index
      event = stripe_event

      Rails.logger.info "Incoming stripe event #{event.type} #{event.data.to_json}"

      StripeService::EventFactory.for(event.type, event.data.object)&.handle

      render json: { success: true }
    end

    private

    def stripe_event
      data = JSON.parse(request.body.read, symbolize_names: true)

      Stripe::Event.construct_from(data)
    end
  end
end
