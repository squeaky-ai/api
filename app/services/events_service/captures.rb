# frozen_string_literal: true

module EventsService
  class Captures
    class << self
      def for(event)
        case event.event_type
        when EventCapture::PAGE_VISIT
          EventsService::Types::PageVisit.new(event)
        when EventCapture::TEXT_CLICK
          EventsService::Types::TextClick.new(event)
        when EventCapture::SELECTOR_CLICK
          EventsService::Types::SelectorClick.new(event)
        when EventCapture::ERROR
          EventsService::Types::Error.new(event)
        when EventCapture::CUSTOM
          EventsService::Types::Custom.new(event)
        else
          raise NotImplementedError, "Unsure how to handle #{event.event_type}"
        end
      end
    end
  end
end
