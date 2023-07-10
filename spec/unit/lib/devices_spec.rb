# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devices do
  describe '.format' do
    let(:device) do
      {
        'browser' => 'safari',
        'useragent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Safari/605.1.15',
        'viewport_x' => 1024,
        'viewport_y' => 768,
        'device_x' => 1024,
        'device_y' => 768,
        'device_type' => 'desktop'
      }
    end

    it 'returns the correct hash' do
      expect(Devices.format(device)).to eq(
        browser_details: 'safari Version 16.2',
        browser_name: 'safari',
        device_type: 'desktop',
        device_x: 1024,
        device_y: 768,
        useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Safari/605.1.15',
        viewport_x: 1024,
        viewport_y: 768,
      )
    end
  end
end
