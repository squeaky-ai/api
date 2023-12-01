# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::Custom do
  describe '#count' do
    let(:now) { Time.current }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT) }

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'my-event' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id,
            groupArray(recording_id) recording_ids
          FROM
            custom_events
          WHERE
            site_id = :site_id AND
            name = 'my-event' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'my-event' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id,
            groupArray(recording_id) recording_ids
          FROM
            custom_events
          WHERE
            site_id = :site_id AND
            name != 'my-event' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: 'other' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id,
            groupArray(recording_id) recording_ids
          FROM
            custom_events
          WHERE
            site_id = :site_id AND
            name LIKE '%other%' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: 'other' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id,
            groupArray(recording_id) recording_ids
          FROM
            custom_events
          WHERE
            site_id = :site_id AND
            name NOT LIKE '%other%' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'my-event' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id,
            groupArray(recording_id) recording_ids
          FROM
            custom_events
          WHERE
            site_id = :site_id AND
            name LIKE 'my-event%' AND
            toDateTime(timestamp / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end
  end
end
