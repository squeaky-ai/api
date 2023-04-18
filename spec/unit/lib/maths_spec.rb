# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Maths do
  describe '.percentage' do
    it 'returns the expected values' do
      expect(described_class.percentage(0, 0)).to eq 0
      expect(described_class.percentage(0, 1)).to eq 0
      expect(described_class.percentage(1, 0)).to eq 0
      expect(described_class.percentage(3, 10)).to eq 30.0
      expect(described_class.percentage(6, 123)).to eq 4.88
      expect(described_class.percentage(312, 32)).to eq 975.0
      expect(described_class.percentage(65, 65)).to eq 100
    end
  end

  describe '.average' do
    it 'returns the expected values' do
      expect(described_class.average([])).to eq 0
      expect(described_class.average([1, 1, 1])).to eq 1
      expect(described_class.average([3, 2, 15])).to eq 6.67
      expect(described_class.average([2, 25, 0])).to eq 9.0
      expect(described_class.average([23])).to eq 23
      expect(described_class.average([0, 0, 0, 5])).to eq 1.25
      expect(described_class.average([32, 12.1, 5, 0])).to eq 12.28
    end
  end
end
