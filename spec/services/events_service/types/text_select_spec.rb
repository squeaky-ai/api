# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsService::Types::TextClick do
  describe '#count' do
    let(:now) { Time.now }

    let(:site) { create(:site, created_at: now) }
    let(:event) { create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK) }

    subject { described_class.new(event).count }

    context 'when the matcher is "equals"' do
      before do
        event.update(rules: [{ matcher: 'equals', condition: 'or', value: 'Add to cart' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector = 'Add to cart' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_equals"' do
      before do
        event.update(rules: [{ matcher: 'not_equals', condition: 'or', value: 'Add to cart' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector != 'Add to cart' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "contains"' do
      before do
        event.update(rules: [{ matcher: 'contains', condition: 'or', value: 'cart' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector LIKE '%cart%' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "not_contains"' do
      before do
        event.update(rules: [{ matcher: 'not_contains', condition: 'or', value: 'Sign up' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector NOT LIKE '%Sign up%' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end

    context 'when the matcher is "starts_with"' do
      before do
        event.update(rules: [{ matcher: 'starts_with', condition: 'or', value: 'Add' }])
      end

      it 'returns the right count' do
        sql = <<-SQL
          SELECT
            COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            selector LIKE 'Add%' AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
        expect(subject).to eq(sql)
      end
    end
  end
end
