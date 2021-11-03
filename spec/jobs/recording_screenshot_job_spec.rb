# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe RecordingScreenshotJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the recording does not exist' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site }
    let(:event) { SecureRandom.base36 }

    subject { described_class.perform_now(event) }

    it 'raises an error' do
      expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the page has not been screenshotted in the refresh time frame' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site(url: 'https://squeaky.ai') }
    let(:event) { recording.id }
    let(:screenshot_s3_key) { 's3_key.jpeg' }
    let(:binary_screenshot) { StringIO.new }
    let(:recording) { create_recording({ pages: [create_page(url: '/')] }, site: site, visitor: create_visitor) }

    before do
      allow(Ferrum::Browser).to receive(:new)
      allow_any_instance_of(Aws::S3::Client).to receive(:put_object)
      allow_any_instance_of(RecordingScreenshotJob).to receive(:screenshot_s3_key).and_return(screenshot_s3_key)
      allow_any_instance_of(RecordingScreenshotJob).to receive(:capture_screenshot).and_return(binary_screenshot)
    end

    subject { described_class.perform_now(event) }

    it 'adds the screenshot to the site' do
      expect { subject }.to change { site.reload.screenshots.size }.from(0).to(1)
    end

    it 'creates the screenshot' do
      subject
      screenshot = site.reload.screenshots.first
      expect(screenshot.url).to eq '/'
      expect(screenshot.site_id).to eq site.id
      expect(screenshot.image_url).to eq "https://cdn.squeaky.ai/screenshots/#{screenshot_s3_key}"
    end

    it 'uploads the screenshot to s3' do
      expect_any_instance_of(Aws::S3::Client).to receive(:put_object).with(
        bucket: 'cdn.squeaky.ai',
        key: "screenshots/#{screenshot_s3_key}",
        body: binary_screenshot
      ) 
      subject
    end
  end

  context 'when the page has not been screenshotted in the refresh time frame' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site(url: 'https://squeaky.ai') }
    let(:event) { recording.id }
    let(:screenshot_s3_key) { 's3_key.jpeg' }
    let(:binary_screenshot) { StringIO.new }
    let(:recording) { create_recording({ pages: [create_page(url: '/')] }, site: site, visitor: create_visitor) }

    before do
      Screenshot.create(site_id: site.id, url: '/')

      allow(Ferrum::Browser).to receive(:new)
      allow_any_instance_of(Aws::S3::Client).to receive(:put_object)
      allow_any_instance_of(RecordingScreenshotJob).to receive(:capture_screenshot).and_return(binary_screenshot)
    end

    subject { described_class.perform_now(event) }

    it 'does not add the screenshot to the site' do
      expect { subject }.not_to change { site.reload.screenshots.size }
    end

    it 'does not upload anything to s3' do
      expect_any_instance_of(Aws::S3::Client).not_to receive(:put_object)
      subject
    end
  end

  context 'when some pages need refreshing but others do not' do
    let(:now) { Time.now.to_i * 1000 }
    let(:site) { create_site(url: 'https://squeaky.ai') }
    let(:event) { recording.id }
    let(:screenshot_s3_key) { 's3_key.jpeg' }
    let(:binary_screenshot) { StringIO.new }
    let(:recording) { create_recording({ pages: [create_page(url: '/'), create_page(url: '/test')] }, site: site, visitor: create_visitor) }

    before do
      Screenshot.create(site_id: site.id, url: '/')

      allow(Ferrum::Browser).to receive(:new)
      allow_any_instance_of(Aws::S3::Client).to receive(:put_object)
      allow_any_instance_of(RecordingScreenshotJob).to receive(:screenshot_s3_key).and_return(screenshot_s3_key)
      allow_any_instance_of(RecordingScreenshotJob).to receive(:capture_screenshot).and_return(binary_screenshot)
    end

    subject { described_class.perform_now(event) }

    it 'adds the one missing screenshot to the site' do
      expect { subject }.to change { site.reload.screenshots.size }.from(1).to(2)
    end

    it 'creates the screenshot' do
      subject
      screenshot = site.reload.screenshots.last
      expect(screenshot.url).to eq '/test'
      expect(screenshot.site_id).to eq site.id
      expect(screenshot.image_url).to eq "https://cdn.squeaky.ai/screenshots/#{screenshot_s3_key}"
    end

    it 'uploads the screenshot to s3' do
      expect_any_instance_of(Aws::S3::Client).to receive(:put_object).with(
        bucket: 'cdn.squeaky.ai',
        key: "screenshots/#{screenshot_s3_key}",
        body: binary_screenshot
      ) 
      subject
    end
  end
end
