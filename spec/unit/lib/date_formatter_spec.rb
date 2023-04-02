# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateFormatter do
  subject { described_class.format(date:, timezone:) }

  context 'when the date is a Date' do
    let(:date) { Date.new(2023, 4, 2) }
    let(:timezone) { 'Europe/London'}

    it 'returns the values' do
      expect(subject).to eq(
        iso8601: '2023-04-02T00:00:00+01:00',
        nice_date: 'Sun, 2 Apr 2023 00:00'
      )  
    end
  end

  context 'when the date is a DateTime' do
    let(:date) { DateTime.new(2023, 4, 2, 8, 12, 3) }
    let(:timezone) { 'Europe/London'}

    it 'returns the values' do
      expect(subject).to eq(
        iso8601: '2023-04-02T09:12:03+01:00',
        nice_date: 'Sun, 2 Apr 2023 09:12'
      )  
    end
  end

  context 'when the date is a millisecond precision integer' do
    let(:date) { DateTime.new(2023, 4, 2, 8, 12, 3).to_i * 1000 }
    let(:timezone) { 'Europe/London'}

    it 'returns the values' do
      expect(subject).to eq(
        iso8601: '2023-04-02T09:12:03+01:00',
        nice_date: 'Sun, 2 Apr 2023 09:12'
      )  
    end
  end
end
