# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::SelectorClick do
  describe '#count' do
    let(:now) { Time.now }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:, event_type: EventCapture::SELECTOR_CLICK) }

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'body > div#test' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector = 'body > div#test' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'body > div#test' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector != 'body > div#test' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: '#test' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector LIKE '%#test%' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: '#test' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector NOT LIKE '%#test%' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'body > div' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector LIKE 'body > div%' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end
  end
end
