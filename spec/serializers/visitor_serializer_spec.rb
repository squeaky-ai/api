# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitorSerializer do
  describe '#serialize' do
    let(:visitor) do
      create(
        :visitor,
        visitor_id: 'd5cipqbhmsi01sc8',
        external_attributes: {
          id: 5,
          first_name: 'Bob',
          last_name: 'Dylan',
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
      expect(subject).to eq(
        id: visitor.id,
        countries: [
          {
            code: 'GB', 
            name: 'United Kingdom'
          },
          {
            code: 'SE', 
            name: 'Sweden'
          }
        ],
        devices: [
          {
            browser_details: 'Firefox Version 96.0',
            browser_name: 'Firefox',
            device_type: 'Desktop',
            device_x: 1920,
            device_y: 1080,
            useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:96.0) Gecko/20100101 Firefox/96.0',
            viewport_x: 1920,
            viewport_y: 1080
          }, 
          {
            browser_details: 'Safari Version 16.2', 
            browser_name: 'Safari', 
            device_type: 'Mobile', 
            device_x: 320, 
            device_y: 420, 
            useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Safari/605.1.15', 
            viewport_x: 320, 
            viewport_y: 420
          }
        ],
        first_viewed_at: '2022-12-15T16:51:18Z',
        language: 'English (GB)',
        last_activity_at: '2022-12-15T16:51:23Z',
        linked_data: {
          id: 5, 
          email: 'bobby@dylan.com', 
          first_name: 'Bob', 
          last_name: 'Dylan'
        },
        recording_count: 2,
        starred: false,
        viewed: false,
        visitor_id: 'd5cipqbhmsi01sc8',
      )
    end
  end
end