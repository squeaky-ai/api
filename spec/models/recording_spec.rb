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
end
