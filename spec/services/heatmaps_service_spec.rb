# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HeatmapsService do
  let(:site) { create(:site) }
  let(:recording) { create(:recording, site:) }
  let(:range) { DateRange.new(from_date: '2022-09-23', to_date: '2022-09-30') }

  let(:instance) do
    described_class.new(
      site_id: site.id,
      range:,
      page_url: '/',
      device: 'Desktop'
    )
  end

  describe '#click_counts' do
    before do
      ClickHouse::ClickEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          url: '/',
          selector: 'p#foo',
          coordinates_x: 10,
          coordinates_y: 10,
          viewport_x: 1920,
          viewport_y: 1080,
          device_x: 1920,
          device_y: 1080,
          relative_to_element_x: 0,
          relative_to_element_y: 0,
          timestamp: 1664543666818
        }
      end
    end

    it 'returns the click counts' do
      expect(instance.click_counts).to match_array(
        [
          {
            'selector' => 'p#foo',
            'count' => 1
          }
        ]
      )
    end
  end

  describe '#click_positions' do
    before do
      ClickHouse::ClickEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          url: '/',
          selector: 'p#foo',
          coordinates_x: 10,
          coordinates_y: 10,
          viewport_x: 1920,
          viewport_y: 1080,
          device_x: 1920,
          device_y: 1080,
          relative_to_element_x: 5,
          relative_to_element_y: 5,
          timestamp: 1664543666818
        }
      end
    end

    it 'returns the click positions' do
      expect(instance.click_positions).to match_array(
        [
          {
            'selector' => 'p#foo',
            'relative_to_element_x' => 5,
            'relative_to_element_y' => 5
          }
        ]
      )
    end
  end

  describe '#cursors' do
    before do
      ClickHouse::CursorEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          url: '/',
          coordinates: [
            {
              x: 10,
              y: 10,
              absolute_x: 10,
              absolute_y: 10
            }
          ].to_json,
          viewport_x: 1920,
          viewport_y: 1080,
          device_x: 1920,
          device_y: 1080,
          timestamp: 1664543666818
        }
      end
    end

    it 'returns the cursors positions' do
      expect(instance.cursors).to match_array(
        [
          {
            'count' => 1,
            'x' => 16,
            'y' => 16
          }
        ]
      )
    end
  end

  describe '#scrolls' do
    before do
      ClickHouse::ScrollEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          url: '/',
          x: 10,
          y: 10,
          viewport_x: 1920,
          viewport_y: 1080,
          device_x: 1920,
          device_y: 1080,
          timestamp: 1664543666818
        }
      end
    end

    it 'returns the click counts' do
      expect(instance.scrolls).to match_array(
        [
          {
            'y' => 10
          }
        ]
      )
    end
  end
end
