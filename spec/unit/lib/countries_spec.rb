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
      it 'returns Unknown' do
        expect(Countries.get_country('__--------....')).to eq 'Unknown'
      end
    end
  end

  describe '.to_code_and_name' do
    context 'when given a known country code' do
      it 'returns the matching country' do
        expect(Countries.to_code_and_name(['GB'])).to eq(
          [
            {
              code: 'GB',
              name: 'United Kingdom'
            }
          ]
        )
      end
    end

    context 'when given an unknown country code' do
      it 'returns nil' do
        expect(Countries.to_code_and_name(['__--------....'])).to eq(
          [
            {
              code: '__--------....',
              name: 'Unknown'
            }
          ]
        )
      end
    end
  end
end
