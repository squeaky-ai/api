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

  describe '.get_locale' do
    context 'when the language is nil' do
      it 'returns unknown' do
        expect(Locale.get_locale(nil)).to eq 'Unknown'
      end
    end

    context 'when the language is empty' do
      it 'returns unknown' do
        expect(Locale.get_locale('')).to eq 'Unknown'
      end
    end

    context 'when given a known language' do
      it 'returns the matching language' do
        expect(Locale.get_locale('English (GB)')).to eq 'en-gb'
      end
    end

    context 'when given an unknown language' do
      it 'returns unknown' do
        expect(Locale.get_locale('sdfdsfdsfs')).to eq 'Unknown'
      end
    end
  end
end
