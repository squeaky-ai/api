# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::Error do
  describe '#count' do
    let(:now) { Time.now }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:, event_type: EventCapture::ERROR) }

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'Oh no' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM events
          WHERE
            site_id = :site_id AND
            type = 100 AND
            replaceOne(JSONExtractString(data, 'message'), 'Error: ', '') = 'Oh no' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'Oh no' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM events
          WHERE
            site_id = :site_id AND
            type = 100 AND
            replaceOne(JSONExtractString(data, 'message'), 'Error: ', '') != 'Oh no' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: 'Oh no' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM events
          WHERE
            site_id = :site_id AND
            type = 100 AND
            replaceOne(JSONExtractString(data, 'message'), 'Error: ', '') LIKE '%Oh no%' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: 'Oh no' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM events
          WHERE
            site_id = :site_id AND
            type = 100 AND
            replaceOne(JSONExtractString(data, 'message'), 'Error: ', '') NOT LIKE '%Oh no%' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'Status code' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM events
          WHERE
            site_id = :site_id AND
            type = 100 AND
            replaceOne(JSONExtractString(data, 'message'), 'Error: ', '') LIKE 'Status code%' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end
  end
end