# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SqueakyClient do
  before do
    ENV['SQUEAKY_API_KEY'] = 'test'
    allow(described_class).to receive(:post)
  end

  describe '#add_event' do
    let(:name) { 'event_name' }
    let(:data) { { foo: 'bar' } }
    let(:user_id) { SecureRandom.uuid }

    subject { described_class.new.add_event(name:, data:, user_id:) }

    it 'sends the expected payload' do
      subject
      expect(described_class).to have_received(:post).with(
        '/events',
        body: {
          name:,
          user_id:,
          data: data.to_json
        }.to_json,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'X-SQUEAKY-API-KEY' => 'test'
        },
        timeout: 5
      )
    end
  end
end
