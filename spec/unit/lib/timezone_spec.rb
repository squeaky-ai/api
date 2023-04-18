# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Timezone do
  describe '.get_country_code' do
    context 'when given a known locale' do
      it 'returns the matching language' do
        expect(Timezone.get_country_code('Europe/London')).to eq 'GB'
      end
    end

    context 'when given an unknown locale' do
      it 'returns nil' do
        expect(Timezone.get_country_code('The moon')).to eq nil
      end
    end
  end
end
