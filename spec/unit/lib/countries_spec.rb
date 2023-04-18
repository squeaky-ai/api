# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Countries do
  describe '.get_country' do
    context 'when given a known country code' do
      it 'returns the matching country' do
        expect(Countries.get_country('GB')).to eq 'United Kingdom'
      end
    end

    context 'when given an unknown country code' do
      it 'returns nil' do
        expect(Countries.get_country('__--------....')).to eq 'Unknown'
      end
    end
  end
end
