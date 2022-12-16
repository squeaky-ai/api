# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingSerializer do
  describe '#serialize' do
    let(:visitor) do
      create(
        :visitor,
        visitor_id: 'd5cipqbhmsi01sc8'
      )
    end

    let(:recording) do
      create(
        :recording,
        visitor:,
        session_id: 'dfg7d89gdfg',
        connected_at: 1671123078086,
        disconnected_at: 1671123080086,
        activity_duration: 2000,
        bookmarked: false,
        viewed: false,
        country_code: 'GB',
        locale: 'en-GB',
        useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15',
        viewport_x: 1920,
        viewport_y: 1080,
        device_x: 1920,
        device_y: 1920,
        referrer: 'https://google.com',
        pages_count: 3,
        browser: 'Safari',
        device_type: 'Computer',
        status: 0,
        timezone: 'Europe/London',
        active_events_count: 5
      )
    end

    subject { described_class.new(recording).serialize }

    it 'serializes the recording' do
      expect(subject).to eq(
        id: recording.id,
        activity_duration: 2000,
        bookmarked: false,
        connected_at: '2022-12-15T16:51:18Z',
        country_code: 'GB',
        country_name: 'United Kingdom',
        device: {
          browser_details: 'Safari Version 15.5', 
          browser_name: 'Safari', 
          device_type: 'Computer', 
          device_x: 1920,
          device_y: 1920, 
          useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15',
          viewport_x: 1920, 
          viewport_y: 1080
        },
        disconnected_at: '2022-12-15T16:51:20Z',
        duration: 2000,
        exit_page: '/',
        inactivity: [],
        language: 'English (GB)',
        note_ids: [],
        nps_score: nil,
        page_count: 1,
        page_views: ['/'],
        referrer: 'https://google.com',
        sentiment_store: nil,
        session_id: 'dfg7d89gdfg',
        site_id: recording.site_id,
        start_page: '/',
        tag_ids: [],
        timezone: 'Europe/London',
        utm_campaign: nil,
        utm_content: nil,
        utm_medium: nil,
        utm_source: nil,
        utm_term: nil,
        viewed: false,
        visitor: {
          id: visitor.id,
          visitor_id: visitor.visitor_id
        }
      )
    end
  end
end
