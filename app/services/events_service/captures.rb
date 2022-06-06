# frozen_string_literal: true

module EventsService
  class Captures
    class << self
      def for(event)
        case event.event_type
        when EventCapture::PAGE_VISIT
          EventsService::Types::PageVisit(event).new
        when EventCapture::TEXT_CLICK
          EventsService::Types::TextCick(event).new
        when EventCapture::SELECTOR_CLICK
          EventsService::Types::SelectorClick(event).new
        when EventCapture::ERROR
          EventsService::Types::Error(event).new
        when EventCapture::CUSTOM
          EventsService::Types::Custom(event).new
        else
          raise NotImplementedError, "Unsure how to handle #{event.event_type}"
        end
      end
    end
  end
end
