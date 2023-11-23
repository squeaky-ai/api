# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session do
  let(:message) do
    {
      site_id: SecureRandom.uuid,
      visitor_id: SecureRandom.uuid,
      session_id: SecureRandom.uuid
    }
  end

  before do
    events_fixture = require_fixture('events.json', compress: true)
    allow(Cache.redis).to receive(:lrange).and_return(events_fixture)
  end

  let(:instance) { Session.new(message) }

  describe '#recording' do
    it 'returns the recording' do
      expect(instance.recording).to eq(
        'device_x' => 3840,
        'device_y' => 1600,
        'locale' => 'en-GB',
        'referrer' => nil,
        'timezone' => 'Europe/London',
        'useragent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:95.0) Gecko/20100101 Firefox/95.0',
        'utm_campaign' => 'my_campaign',
        'utm_content' => 'test',
        'utm_medium' => 'organic',
        'utm_source' => 'google',
        'utm_term' => 'analytics',
        'gad' => 'gad',
        'gclid' => 'gclid',
        'viewport_x' => 1813,
        'viewport_y' => 1813
      )
    end
  end

  describe '#pageviews' do
    it 'returns the pageviews' do
      expect(instance.pageviews).to match_array([
        {
          'path' => '/examples/static/',
          'timestamp' => 1637177342265
        }
      ])
    end
  end

  describe '#clicks' do
    it 'returns the clicks' do
      expect(instance.clicks).to match_array([
        {
          'data' => {
            'id' => 31,
            'selector' => 'html > body > form > div:nth-of-type(2) > input',
            'source' => 2,
            'type' => 2,
            'x' => 74,
            'y' => 86
          },
          'timestamp' => 1637177349467,
          'type' => 3
        },
        {
          'data' => {
            'id' => 23,
            'selector' => 'html > body > form > div > input',
            'source' => 2,
            'type' => 2,
            'x' => 79,
            'y' => 74
          },
          'timestamp' => 1637177350203,
          'type' => 3
        },
        {
          'data' => {
            'id' => 34,
            'selector' => 'html > body > form > div:nth-of-type(3)',
            'source' => 2,
            'type' => 2,
            'x' => 571,
            'y' => 123
          },
          'timestamp' => 1637177351329,
          'type' => 3
        }
      ])
    end
  end

  describe '#custom_tracking' do
    it 'returns the custom tracking' do
      expect(instance.custom_tracking).to match_array([
        {
          'data' => {
            'foo' => 'bar',
            'href' => '/examples/static/', 'name' => 'my-event'
          },
          'timestamp' => 1637177342311,
          'type' => 101
        }
      ])
    end
  end

  describe '#errors' do
    it 'returns the errors' do
      expect(instance.errors).to match_array([
        {
          'data' => {
            'line_number' => 74,
            'col_number' => 25,
            'message' => 'Error: Oh no',
            'stack' => 'onclick@http://localhost:8081/examples/static/#:74:16',
            'filename' => 'http://localhost:8081/examples/static/#',
            'href' => '/examples/static/'
          },
          'timestamp' => 1637177342309,
          'type' => 100
        }
      ])
    end
  end

  describe '#locale' do
    it 'returns the locale' do
      expect(instance.locale).to eq 'en-GB'
    end
  end

  describe '#useragent' do
    it 'returns the useragent' do
      expect(instance.useragent).to eq 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:95.0) Gecko/20100101 Firefox/95.0'
    end
  end

  describe '#viewport_x' do
    it 'returns the viewport_x' do
      expect(instance.viewport_x).to eq 1813
    end
  end

  describe '#viewport_y' do
    it 'returns the viewport_y' do
      expect(instance.viewport_y).to eq 1813
    end
  end

  describe '#device_x' do
    it 'returns the device_x' do
      expect(instance.device_x).to eq 3840
    end
  end

  describe '#device_y' do
    it 'returns the device_y' do
      expect(instance.device_y).to eq 1600
    end
  end

  describe '#referrer' do
    it 'returns the referrer' do
      expect(instance.referrer).to eq nil
    end
  end

  describe '#connected_at' do
    it 'returns the connected_at' do
      expect(instance.connected_at).to eq 1637177342265
    end
  end

  describe '#disconnected_at' do
    it 'returns the disconnected_at' do
      expect(instance.disconnected_at).to eq 1637177353431
    end
  end

  describe '#duration' do
    it 'returns the duration' do
      expect(instance.duration).to eq 11166
    end
  end

  describe '#timezone' do
    it 'returns the timezone' do
      expect(instance.timezone).to eq 'Europe/London'
    end
  end

  describe '#country_code' do
    it 'returns the country code' do
      expect(instance.country_code).to eq 'GB'
    end
  end

  describe '#pages' do
    it 'returns the pages' do
      expect(instance.pages).to match_array([
        {
          url: '/examples/static/',
          entered_at: 1637177342265,
          exited_at: 1637177353431,
          duration: 11166,
          activity_duration: 11166,
          bounced_on: true,
          exited_on: true
        }
      ])
    end

    context 'when there is some inactivity' do
      let(:inactivity) do
        [
          [100, 200],
          [18000, 18100]
        ]
      end
      let(:events_activity) { instance_double(Events::Activity, inactivity:) }

      let(:pageviews) do
        [
          {
            'path' => '/examples/static/',
            'timestamp' => 1637177342265
          },
          {
            'path' => '/examples/static/1',
            'timestamp' => 1637177345265
          }
        ]
      end

      before do
        allow(instance).to receive(:pageviews).and_return(pageviews)
        allow(Events::Activity).to receive(:new).and_return(events_activity)
      end

      it 'returns the pages' do
        expect(instance.pages).to eq([
          {
            url: '/examples/static/',
            entered_at: 1637177342265,
            exited_at: 1637177345265,
            duration: 3000,
            activity_duration: 2900,
            bounced_on: false,
            exited_on: false
          },
          {
            url: '/examples/static/1',
            entered_at: 1637177345265,
            exited_at: 1637177353431,
            duration: 8166,
            activity_duration: 8166,
            bounced_on: false,
            exited_on: true
          }
        ])
      end
    end
  end

  describe '#events?' do
    it 'returns whether there are events' do
      expect(instance.events?).to eq true
    end
  end

  describe '#pageviews?' do
    it 'returns whether there are pageviews' do
      expect(instance.pageviews?).to eq true
    end
  end

  describe '#recording?' do
    it 'returns whether there are all the properties required for a recording' do
      expect(instance.recording?).to eq true
    end
  end

  describe '#interaction?' do
    it 'returns whether there was any user interaction' do
      expect(instance.interaction?).to eq true
    end
  end

  describe '#utm_source' do
    it 'returns the utm source' do
      expect(instance.utm_source).to eq 'google'
    end
  end

  describe '#utm_medium' do
    it 'returns the utm medium' do
      expect(instance.utm_medium).to eq 'organic'
    end
  end

  describe '#utm_campaign' do
    it 'returns the utm campaign' do
      expect(instance.utm_campaign).to eq 'my_campaign'
    end
  end

  describe '#utm_content' do
    it 'returns the utm content' do
      expect(instance.utm_content).to eq 'test'
    end
  end

  describe '#utm_term' do
    it 'returns the utm term' do
      expect(instance.utm_term).to eq 'analytics'
    end
  end

  describe '#gad' do
    it 'returns the gad' do
      expect(instance.gad).to eq 'gad'
    end
  end

  describe '#gclid' do
    it 'returns the gclid' do
      expect(instance.gclid).to eq 'gclid'
    end
  end

  describe '#custom_tracking' do
    it 'returns the custom events' do
      expect(instance.custom_tracking.size).to eq 1
    end
  end

  describe '#errors' do
    it 'returns the errors' do
      expect(instance.errors.size).to eq 1
    end
  end

  context 'when the events include some bad json' do
    before do
      event_1 = { key: 'event', value: { timestamp: 1651157003244 } }.to_json
      event_2 = 'sdfdsf{}11@@@2'

      allow(Cache.redis).to receive(:lrange).and_return(compress_events([event_1, event_2]))
      allow(Rails.logger).to receive(:warn).and_call_original
    end

    it 'skips bad events' do
      expect(instance.events.size).to eq 0
    end

    it 'logs a warning' do
      instance
      expect(Rails.logger).to have_received(:warn)
    end
  end

  describe '#exists?' do
    context 'when the session does not exist' do
      it 'returns false' do
        expect(instance.exists?).to eq false
      end
    end

    context 'when the session does exist' do
      before do
        create(:recording, session_id: instance.session_id)
      end

      it 'returns true' do
        expect(instance.exists?).to eq true
      end
    end
  end

  describe '#inactivity' do
    it 'returns the inactivity' do
      expect(instance.inactivity).to eq []
    end
  end

  describe '#activity_duration' do
    it 'returns the inactivity duration' do
      expect(instance.activity_duration).to eq 11166
    end
  end

  describe '#scrolls' do
    it 'returns the scrolls' do
      expect(instance.scrolls.size).to eq 40
    end
  end

  describe '#cursors' do
    it 'returns the cursors' do
      expect(instance.cursors.size).to eq 21
    end
  end

  describe '#active_events_count' do
    it 'returns the count' do
      expect(instance.active_events_count).to eq 27
    end
  end

  describe '#sentiments' do
    it 'returns the sentiments' do
      expect(instance.sentiments).to eq([
        {
          comment: 'Hello',
          score: '2'
        }
      ])
    end
  end

  describe '#nps' do
    it 'returns the nps' do
      expect(instance.nps).to eq(
        comment: 'Hello',
        contact: true,
        email: 'bobby@gmail.com',
        score: '9'
      )
    end
  end

  describe '#rage_click?' do
    context 'when there are less than 5 clicks' do
      it 'returns false' do
        expect(instance.rage_clicked?).to eq(false)
      end
    end

    context 'when there was no range click' do
      before do
        allow(instance).to receive(:clicks).and_return([
          {
            'timestamp' => 1688155262000
          },
          {
            'timestamp' => 1688155271000
          },
          {
            'timestamp' => 1688155274000
          },
          {
            'timestamp' => 1688155277000
          },
          {
            'timestamp' => 1688155280000
          },
          {
            'timestamp' => 1688155289000
          }
        ])
      end

      it 'returns false' do
        expect(instance.rage_clicked?).to eq(false)
      end
    end

    context 'when there was a range click' do
      before do
        allow(instance).to receive(:clicks).and_return([
          {
            'timestamp' => 1688223351821
          },
          {
            'timestamp' => 1688223351978
          },
          {
            'timestamp' => 1688223352110
          },
          {
            'timestamp' => 1688223352237
          },
          {
            'timestamp' => 1688223352369
          },
          {
            'timestamp' => 1688223352501
          },
          {
            'timestamp' => 1688223352633
          },
          {
            'timestamp' => 1688223352771
          },
          {
            'timestamp' => 1688223352898
          },
          {
            'timestamp' => 1688223353032
          },
          {
            'timestamp' => 1688223353166
          },
          {
            'timestamp' => 1688223353300
          },
          {
            'timestamp' => 1688223353442
          },
          {
            'timestamp' => 1688223353689
          },
          {
            'timestamp' => 1688223353840
          },
          {
            'timestamp' => 1688223357222
          },
          {
            'timestamp' => 1688223361888
          },
          {
            'timestamp' => 1688223364338
          }
        ])
      end

      it 'returns true' do
        expect(instance.rage_clicked?).to eq(true)
      end
    end
  end

  describe '#u_turned?' do
    context 'when there was no u_turn' do
      context 'because there was not enough pages' do
        before do
          allow(instance).to receive(:pages).and_return([
            {
              url: '/',
              duration: 1000
            },
            {
              url: '/foo',
              duration: 1000
            }
          ])
        end

        it 'returns false' do
          expect(instance.u_turned?).to eq(false)
        end
      end

      context 'because they did not return to previous the page' do
        before do
          allow(instance).to receive(:pages).and_return([
            {
              url: '/',
              duration: 1000
            },
            {
              url: '/foo',
              duration: 1000
            },
            {
              url: '/bar',
              duration: 1000
            }
          ])
        end

        it 'returns false' do
          expect(instance.u_turned?).to eq(false)
        end
      end

      context 'because they were on the middle page for too long' do
        before do
          allow(instance).to receive(:pages).and_return([
            {
              url: '/',
              duration: 1000
            },
            {
              url: '/foo',
              duration: 8000
            },
            {
              url: '/',
              duration: 1000
            }
          ])
        end

        it 'returns false' do
          expect(instance.u_turned?).to eq(false)
        end
      end
    end

    context 'when there was a u_turn' do
      before do
        allow(instance).to receive(:pages).and_return([
          {
            url: '/',
            duration: 1000
          },
          {
            url: '/foo',
            duration: 5000
          },
          {
            url: '/',
            duration: 1000
          }
        ])
      end

      it 'returns true' do
        expect(instance.u_turned?).to eq(true)
      end
    end
  end
end
