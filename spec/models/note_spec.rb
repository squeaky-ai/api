# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  describe '#session_id' do
    let(:site) { create_site }
    let(:recording) { create_recording(site: site, visitor: create_visitor) }
    
    subject { described_class.new(recording: recording) }

    it 'returns the session id' do
      expect(subject.session_id).to eq recording.session_id
    end
  end
end
