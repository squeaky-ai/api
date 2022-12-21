# frozen_string_literal: true

module DataCacheService
  module Sites
    class Settings < DataCacheService::Base
      def call # rubocop:disable Metrics/AbcSize
        cache do
          # Weird that we're fetching the site when the site is already in
          # scope, however the site is just an in memory instance with a
          # uuid. This should probably be a one off! The fields are also
          # public so be careful what gets exposed
          s = Site.find_by(uuid: site.uuid)

          return unless s

          {
            name: s.name,
            url: s.url,
            uuid: s.uuid,
            css_selector_blacklist: s.css_selector_blacklist,
            anonymise_form_inputs: s&.anonymise_form_inputs,
            anonymise_text: s&.anonymise_text,
            ingest_enabled: s.ingest_enabled,
            ip_blacklist: s.ip_blacklist,
            magic_erasure_enabled: s.magic_erasure_enabled_for_user?(user),
            invalid_or_exceeded_plan: s.plan.exceeded? || s.plan.invalid?,
            feedback: s.feedback,
            consent: s.consent
          }
        end
      end
    end
  end
end
