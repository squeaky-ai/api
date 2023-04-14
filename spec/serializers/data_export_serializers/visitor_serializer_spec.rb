# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataExportSerializers::VisitorSerializer do
  describe '#serialize' do
    let(:visitor) do
      create(
        :visitor,
        visitor_id: 'd5cipqbhmsi01sc8',
        external_attributes: {
          id: 5,
          name: 'Bob Dylan',
          email: 'bobby@dylan.com'
        }
      )
    end

    before do
      create(
        :recording, 
        visitor:, 
        country_code: 'GB',
        connected_at: 1671123078086,
        disconnected_at: 1671123080086,
      )

      create(
        :recording, 
        visitor:, 
        country_code: 'SE',
        device_type: 'Mobile',
        browser: 'Safari',
        device_x: 320,
        device_y: 420,
        viewport_x: 320,
        viewport_y: 420,
        useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Safari/605.1.15',
        connected_at: 1671123081086,
        disconnected_at: 1671123083086,
      )
    end

    subject { described_class.new(visitor).serialize }

    it 'serializes the visitor' do
      expect(subject).to match(
        id: visitor.id,
        status: 'New',
        browsers: 'Firefox|Safari',
        country_codes: 'GB|SE',
        first_viewed_at: '2022-12-15T16:51:18Z',
        languages: 'English (GB)',
        last_activity_at: '2022-12-15T16:51:23Z',
        email: 'bobby@dylan.com', 
        user_id: 5,
        name: 'Bob Dylan',
        recording_count: 2,
        visitor_id: 'd5cipqbhmsi01sc8',
        source: nil
      )
    end
  end
end
