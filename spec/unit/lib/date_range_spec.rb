# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateRange do
  let(:scenarios) do
    [
      {
        in: {
          from: Date.new(2021, 12, 22),
          to: Date.new(2021, 12, 29)
        },
        out: {
          from: Date.new(2021, 12, 15),
          to: Date.new(2021, 12, 22)
        }
      },
      {
        in: {
          from: Date.new(2021, 12, 15),
          to: Date.new(2021, 12, 29)
        },
        out: {
          from: Date.new(2021, 12, 1),
          to: Date.new(2021, 12, 15)
        }
      },
      {
        in: {
          from: Date.new(2021, 12, 29),
          to: Date.new(2021, 12, 29)
        },
        out: {
          from: Date.new(2021, 12, 28),
          to: Date.new(2021, 12, 28)
        }
      },
      {
        in: {
          from: Date.new(2021, 10, 29),
          to: Date.new(2021, 12, 29)
        },
        out: {
          from: Date.new(2021, 8, 29),
          to: Date.new(2021, 10, 29)
        }
      }
    ]
  end

  it 'exposes the dates' do
    scenarios.each do |scenario|
      range = DateRange.new(scenario[:in][:from], scenario[:in][:to])
      expect(range.from).to eq(scenario[:in][:from])
      expect(range.to).to eq(scenario[:in][:to])
    end
  end

  it 'offsets the dates by their diff' do
    scenarios.each do |scenario|
      range = DateRange.new(scenario[:in][:from], scenario[:in][:to])
      expect(range.trend_from).to eq(scenario[:out][:from])
      expect(range.trend_to).to eq(scenario[:out][:to])
    end
  end
end