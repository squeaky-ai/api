# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::UtmParameters do
  describe '#count' do
    let(:now) { Time.current }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:, event_type: EventCapture::UTM_PARAMETERS) }

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'google', field: 'utm_source' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            utm_source = 'google' AND
            toDateTime(disconnected_at / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'google', field: 'utm_source' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            utm_source != 'google' AND
            toDateTime(disconnected_at / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: 'google', field: 'utm_source' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            utm_source LIKE '%google%' AND
            toDateTime(disconnected_at / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: 'google', field: 'utm_source' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            utm_source NOT LIKE '%google%' AND
            toDateTime(disconnected_at / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'google', field: 'utm_source' }])
      end

      it 'returns the right count' do
        sql = <<-SQL.squish
          SELECT
            COUNT(*) count,
            COUNT(DISTINCT visitor_id) unique_triggers,
            '#{event.name}' as event_name,
            '#{event.id}' as event_id
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            utm_source LIKE 'google%' AND
            toDateTime(disconnected_at / 1000, :timezone) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end
  end
end
