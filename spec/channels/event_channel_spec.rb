# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

basic_events_fixture = [
  {'payload'=>{'type'=>4, 'data'=>{'href'=>'http://localhost:8080/', 'width'=>1920, 'height'=>1080, 'locale'=>'en-GB', 'useragent'=>'Firefox'}, 'timestamp'=>1631130450392}, 'action'=>'event'},
  {'payload'=>{'type'=>3, 'data'=>{}, 'timestamp'=>1631130450852}, 'action'=>'event'},
  {'payload'=>{'type'=>3, 'data'=>{}, 'timestamp'=>1631130455897}, 'action'=>'event'}
]

RSpec.describe EventChannel, :type => :channel do
  describe 'when the recording is simple' do
    let(:current_visitor) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.base36,
        session_id: SecureRandom.base36
      }
    end

    before do
      allow_any_instance_of(Aws::SQS::Client).to receive(:send_message)
    end

    it 'stores the recording' do
      stub_connection current_visitor: current_visitor

      subscribe
      basic_events_fixture.each { |e| perform :event, **e }

      recording = Redis.current.hgetall("recording::#{current_visitor[:site_id]}::#{current_visitor[:session_id]}")

      expect(recording).to eq(
        'useragent' => 'Firefox',
        'locale' => 'en-GB',
        'height' => '1080',
        'width' => '1920',
        'page_views' => '/'
      )
    end

    it 'stores the events' do
      stub_connection current_visitor: current_visitor

      subscribe
      basic_events_fixture.each { |e| perform :event, **e }

      events = Redis.current.lrange("events::#{current_visitor[:site_id]}::#{current_visitor[:session_id]}", 0, -1)

      expect(events.size).to eq 3
    end
  end

  describe 'when the recording has identification' do
    let(:current_visitor) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.base36,
        session_id: SecureRandom.base36
      }
    end

    before do
      allow_any_instance_of(Aws::SQS::Client).to receive(:send_message)
    end

    it 'stores the recording with the indentity' do
      stub_connection current_visitor: current_visitor

      subscribe
      basic_events_fixture.each { |e| perform :event, **e }

      perform :identify, {'payload'=>{'id'=>5,'email'=>'foo@bar.com'}}

      recording = Redis.current.hgetall("recording::#{current_visitor[:site_id]}::#{current_visitor[:session_id]}")

      expect(recording).to eq(
        'useragent' => 'Firefox',
        'locale' => 'en-GB',
        'height' => '1080',
        'width' => '1920',
        'page_views' => '/',
        'identify' => '{"id":5,"email":"foo@bar.com"}'
      )
    end

    it 'stores the events' do
      stub_connection current_visitor: current_visitor

      subscribe
      basic_events_fixture.each { |e| perform :event, **e }

      events = Redis.current.lrange("events::#{current_visitor[:site_id]}::#{current_visitor[:session_id]}", 0, -1)

      expect(events.size).to eq 3
    end
  end

  describe 'when the recording has some additional page views' do
    let(:current_visitor) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.base36,
        session_id: SecureRandom.base36
      }
    end

    before do
      allow_any_instance_of(Aws::SQS::Client).to receive(:send_message)
    end

    it 'stores the recording with the indentity' do
      stub_connection current_visitor: current_visitor

      subscribe
      basic_events_fixture.each { |e| perform :event, **e }

      perform :pageview, {'payload'=>{'data'=>'http://localhost:8080/test'}}

      recording = Redis.current.hgetall("recording::#{current_visitor[:site_id]}::#{current_visitor[:session_id]}")

      expect(recording).to eq(
        'useragent' => 'Firefox',
        'locale' => 'en-GB',
        'height' => '1080',
        'width' => '1920',
        'page_views' => '/,/test'
      )
    end
  end

  describe 'when the user disconnects' do
    let(:current_visitor) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.base36,
        session_id: SecureRandom.base36
      }
    end

    before do
      allow_any_instance_of(Aws::SQS::Client).to receive(:send_message)
    end

    it 'enqueues the saving of the recording' do
      stub_connection current_visitor: current_visitor

      subscribe
      basic_events_fixture.each { |e| perform :event, **e }

      expect_any_instance_of(Aws::SQS::Client).to receive(:send_message).with(
        message_body: current_visitor.to_json,
        queue_url: 'QUEUE_MISSING'
      )

      unsubscribe
    end
  end
end
