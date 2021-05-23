# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recording, type: :model do
  describe '#page_count' do
    subject do
      pages = ['/', '/', '/pricing', '/pricing', '/pricing/test']
      described_class.new(page_views: pages)
    end

    it 'returns the number of pages visited' do
      expect(subject.page_count).to eq 3
    end
  end

  describe '#duration' do
    subject do
      created_at = (DateTime.now - 5 / 86_400.0)
      updated_at = DateTime.now
      described_class.new(created_at: created_at, updated_at: updated_at)
    end

    it 'returns the difference between the connected and disconnected dates' do
      expect(subject.duration).to eq 5
    end
  end

  describe '#start_page' do
    context 'when there are no page views' do
      subject { described_class.new }

      it 'returns a ?' do
        expect(subject.start_page).to eq '?'
      end
    end

    context 'when there are page views' do
      subject do
        pages = ['/', '/', '/pricing', '/pricing', '/pricing/test']
        described_class.new(page_views: pages)
      end

      it 'returns the start_page' do
        expect(subject.start_page).to eq '/'
      end
    end
  end

  describe '#exit_page' do
    context 'when there are no page views' do
      subject { described_class.new }

      it 'returns a ?' do
        expect(subject.exit_page).to eq '?'
      end
    end

    context 'when there are page views' do
      subject do
        pages = ['/', '/', '/pricing', '/pricing', '/pricing/test']
        described_class.new(page_views: pages)
      end

      it 'returns the exit_page' do
        expect(subject.exit_page).to eq '/pricing/test'
      end
    end
  end
end
