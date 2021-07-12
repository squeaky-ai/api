# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe '#to_h' do
    it 'serializes the tag' do
      tag = Tag.new(name: 'Foo')
      expect(tag.to_h).to eq(id: tag.id, name: tag.name)
    end
  end
end
