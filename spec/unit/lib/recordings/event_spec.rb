# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recordings::Event do
  describe '.validate!' do
    context 'when the data is totally not valid' do
      let(:event) do
        {
          foo: 'bar'
        }
      end

      subject { described_class.validate!(event) }

      it 'raises an error' do
        expect { subject }.to raise_error JSON::Schema::ValidationError
      end
    end

    context 'when the data is missing some stuff' do
      let(:event) do
        {
          href: '/',
          locale: 'en-gb',
          position: 0,
          useragent: Faker::Internet.user_agent,
          timestamp: 0,
          mouse_x: 0,
          mouse_y: 0
        }
      end

      subject { described_class.validate!(event) }

      it 'raises an error' do
        expect { subject }.to raise_error JSON::Schema::ValidationError
      end
    end

    context 'when the data is valid but has extra stuff' do
      let(:event) do
        {
          href: '/',
          locale: 'en-gb',
          position: 0,
          useragent: Faker::Internet.user_agent,
          timestamp: 0,
          mouse_x: 0,
          mouse_y: 0,
          scroll_x: 0,
          scroll_y: 0,
          viewport_x: 0,
          viewport_y: 0,
          should_not_exist: '!!'
        }
      end

      subject { described_class.validate!(event) }

      it 'raises an error' do
        expect { subject }.to raise_error JSON::Schema::ValidationError
      end
    end

    context 'when the data is valid' do
      let(:event) do
        {
          href: '/',
          locale: 'en-gb',
          position: 0,
          useragent: Faker::Internet.user_agent,
          timestamp: 0,
          mouse_x: 0,
          mouse_y: 0,
          scroll_x: 0,
          scroll_y: 0,
          viewport_x: 0,
          viewport_y: 0
        }
      end

      subject { described_class.validate!(event) }

      it 'returns the event' do
        expect(subject).to eq event
      end
    end
  end
end
