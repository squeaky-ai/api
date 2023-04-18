# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Visitor, type: :model do
  describe '#viewed?' do
    context 'when no sessions have been viewed including this visitor' do
      let(:site) { create(:site) }
      let(:visitor) { create(:visitor) }
      
      before do
        create(:recording, site: site)
      end

      subject { visitor.reload.viewed? }

      it 'returns false' do
        expect(subject).to eq false
      end
    end

    context 'when sessions have been viewed including this visitor' do
      let(:site) { create(:site) }
      let(:visitor) { create(:visitor) }

      before do
        create(:recording, viewed: true, site: site, visitor: visitor)
      end

      subject { visitor.reload.viewed? }

      it 'returns true' do
        visitor.recordings
        expect(subject).to eq true
      end
    end
  end
end
