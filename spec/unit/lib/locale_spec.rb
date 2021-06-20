# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locale do
  describe '.get_language' do
    context 'when given a known locale' do
      it 'returns the matching language' do
        expect(Locale.get_language('en-gb')).to eq 'English (GB)'
      end
    end

    context 'when given a known locale in the wrong case' do
      it 'returns the matching language' do
        expect(Locale.get_language('en-GB')).to eq 'English (GB)'
      end
    end

    context 'when given an unknown locale' do
      it 'returns unknown' do
        expect(Locale.get_language('zz-zz')).to eq 'Unknown'
      end
    end
  end
end
