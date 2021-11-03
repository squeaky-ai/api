# frozen_string_literal: true

require 'securerandom'

# Pick up messages from SQS and fetch screenshots
# for all the pages in a recording if they don't
# already exist
class RecordingScreenshotJob < ApplicationJob
  queue_as :default

  REFRESH_DURATION = 1.week.freeze

  CDN_URL = 'https://cdn.squeaky.ai/screenshots'

  before_perform do |job|
    recording_id = job.arguments[0]

    @recording = Recording.find(recording_id)
    @site = @recording.site
  end

  def perform(*_args, **_kwargs)
    paths = @recording.pages.map(&:url)

    # Spin up the browser once and reuse it
    @browser = Ferrum::Browser.new(browser_options: { 'no-sandbox': nil })

    @browser.network.intercept

    # Disable all websocket connections as they will hang
    @browser.on(:request) do |request|
      if request.resource_type == 'WebSocket'
        request.abort
      else
        request.continue
      end
    end

    capture_screenshots(paths)
    @browser&.quit
  end

  private

  def capture_screenshots(paths)
    paths.each do |path|
      next unless refresh_required?(path)

      screenshot = capture_screenshot(path)
      image_url = upload_to_s3(screenshot)

      @site.screenshots.create(url: path, image_url: image_url)
    end
  end

  def capture_screenshot(path)
    @browser.go_to(@site.url + path)
    @browser.mouse.scroll_to(0, 10_000)
    @browser.network.wait_for_idle
    @browser.screenshot(full: true, format: 'jpeg', encoding: :binary)
  end

  def refresh_required?(path)
    from_date = Time.now
    to_date = from_date - REFRESH_DURATION

    @site.screenshots.where('url = ? AND created_at <= ? AND created_at >= ?', path, from_date, to_date).empty?
  end

  def screenshot_s3_key
    "#{SecureRandom.uuid}.jpeg"
  end

  def upload_to_s3(screenshot)
    client = Aws::S3::Client.new
    key = screenshot_s3_key

    client.put_object(bucket: 'cdn.squeaky.ai', key: "screenshots/#{key}", body: screenshot)

    "#{CDN_URL}/#{key}"
  end
end
