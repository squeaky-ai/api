# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe Trend do
  it 'offsets the dates by their diff' do
    scenarios = [
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

    scenarios.each do |scenario|
      response = Trend.offset_period(scenario[:in][:from], scenario[:in][:to])
      expect(response).to eq([scenario[:out][:from], scenario[:out][:to]])
    end
  end
end
