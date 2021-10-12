# frozen_string_literal: true

require 'date'
require 'rails_helper'
require 'securerandom'

RSpec.describe Visitor, type: :model do
  describe '#to_h' do
    let(:site) { create_site }
    let(:fixture) { { site_id: site.id, connected_at: Time.new(2021, 9, 24, 12, 12, 45).to_i * 1000, disconnected_at: Time.new(2021, 9, 24, 12, 12, 47).to_i * 1000, useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15' } }
    let(:visitor) { create_visitor }
    let(:recording) { create_recording(fixture, site: site, visitor: visitor) }

    before { recording }

    subject { visitor.reload.to_h }

    it 'returns the hashed version' do
      expect(subject).to eq(
        id: visitor.id,
        site_id: site.id,
        visitor_id: visitor.visitor_id,
        attributes: {},
        first_viewed_at: '2021-09-24T11:12:45Z',
        last_activity_at: '2021-09-24T11:12:47Z',
        locale: 'en-GB',
        language: 'English (GB)',
        devices: [
          {
            browser_details: 'Safari Version 14.1.1',
            browser_name: 'Safari',
            device_type: 'Computer',
            useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15',
            viewport_x: 1920,
            viewport_y: 1080
          }
        ]
      )
    end
  end
end
