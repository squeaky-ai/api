# frozen_string_literal: true

class Devices
  def self.format(device)
    {
      browser_name: device['browser'] || 'Unknown',
      browser_details: "#{device['browser']} Version #{UserAgent.parse(device['useragent']).version}",
      viewport_x: device['viewport_x'] || 0,
      viewport_y: device['viewport_y'] || 0,
      device_x: device['device_x'] || 0,
      device_y: device['device_y'] || 0,
      device_type: device['device_type'] || 'Unknown',
      useragent: device['useragent']
    }
  end
end
