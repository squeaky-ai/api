# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  describe '#to_h' do
    let(:user) { create_user }

    it 'serializes the note' do
      note = Note.new(body: 'Foo', timestamp: 1000, user: user)

      expect(note.to_h).to eq({
        id: note.id, 
        body: note.body,
        timestamp: 1000,
        user: user.to_h,
        created_at: nil,
        updated_at: nil
      })
    end

    context 'when the timestamp is missing' do
      it 'serializes the note' do
        note = Note.new(body: 'Foo', timestamp: nil, user: user)
  
        expect(note.to_h).to eq({
          id: note.id, 
          body: note.body,
          timestamp: nil,
          user: user.to_h,
          created_at: nil,
          updated_at: nil
        })
      end
    end
  end
end
