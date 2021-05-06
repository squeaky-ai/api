# frozen_string_literal: true

require 'date'
require 'rails_helper'
require 'securerandom'

RSpec.describe Recording, type: :model do
  def recording_fixture
    {
      site_id: SecureRandom.uuid,
      session_id: Faker::String.random(length: 8),
      viewer_id: Faker::String.random(length: 8),
      locale: 'en-gb',
      start_page: '/',
      exit_page: '/pricing',
      useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15',
      viewport_x: 1920,
      viewport_y: 1080,
      active: false,
      page_views: Set.new,
      connected_at: DateTime.now.iso8601,
      disconnected_at: DateTime.now.iso8601
    }
  end

  describe '#serialize' do
    let(:instance) { described_class.new(recording_fixture) }

    it 'contains the expected key' do
      expect(instance.serialize.keys).to eq %i[
        id
        user
        active
        locale
        duration
        page_count
        start_page
        exit_page
        useragent
        viewport_x
        viewport_y
      ]
    end
  end

  describe '#page_count' do
    let(:instance) do
      fixture = recording_fixture.dup
      fixture[:page_views] = Set.new(['/', '/pricing', '/pricing/test'])
      described_class.new(fixture)
    end

    it 'returns the number of pages visited' do
      expect(instance.page_count).to eq 3
    end
  end

  describe '#duration' do
    let(:instance) do
      fixture = recording_fixture.dup
      fixture[:connected_at] = (DateTime.now - 5 / 86_400.0).iso8601
      fixture[:disconnected_at] = DateTime.now.iso8601
      described_class.new(fixture)
    end

    it 'returns the difference between the connected and disconnected dates' do
      expect(instance.duration).to eq 5
    end
  end
end
