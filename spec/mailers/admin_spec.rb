# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminMailer, type: :mailer do
  describe '#site_destroyed' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject { described_class.site_destroyed(site) }

    it 'renders the headers' do
      expect(subject.subject).to eq 'Site deleted'
      expect(subject.to).to eq ['hello@squeaky.ai']
      expect(subject.from).to eq ['hello@squeaky.ai']
    end
  end
end
