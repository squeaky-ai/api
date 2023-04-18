# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  describe '#session_id' do
    let(:site) { create(:site) }
    let(:recording) { create(:recording, site: site) }
    
    subject { described_class.new(recording: recording) }

    it 'returns the session id' do
      expect(subject.session_id).to eq recording.session_id
    end
  end
end
