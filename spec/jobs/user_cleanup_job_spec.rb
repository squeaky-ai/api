# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserCleanupJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class.perform_now }
  
  context 'when there are no users to delete' do
    it 'does not delete anyone' do
      expect { subject }.not_to change { User.all.count }
    end
  end

  context 'when there are some users to delete' do
    before do
      now = Time.now

      # Invited and unconfirmed
      create(:user, invitation_created_at: now, confirmed_at: nil, created_at: now - 24.hours)
      create(:user, invitation_created_at: now, confirmed_at: nil, created_at: now - 36.hours)
      create(:user, invitation_created_at: now, confirmed_at: nil, created_at: now - 49.hours)
      create(:user, invitation_created_at: now, confirmed_at: nil, created_at: now - 72.hours)

      # Invited and confirmed
      create(:user, invitation_created_at: now, confirmed_at: now, created_at: now - 24.hours)
      create(:user, invitation_created_at: now, confirmed_at: now, created_at: now - 36.hours)
      create(:user, invitation_created_at: now, confirmed_at: now, created_at: now - 49.hours)
      create(:user, invitation_created_at: now, confirmed_at: now, created_at: now - 72.hours)

      # Manually created and unconfirmed
      create(:user, confirmed_at: nil, created_at: now - 24.hours)
      create(:user, confirmed_at: nil, created_at: now - 36.hours)
      create(:user, confirmed_at: nil, created_at: now - 49.hours) # Should delete
      create(:user, confirmed_at: nil, created_at: now - 72.hours) # Should delete

      # Manually created and confirmed
      create(:user, confirmed_at: now, created_at: now - 24.hours)
      create(:user, confirmed_at: now, created_at: now - 36.hours)
      create(:user, confirmed_at: now, created_at: now - 49.hours)
      create(:user, confirmed_at: now, created_at: now - 72.hours)
    end

    it 'only deletes the ones that are unconfirmed after 48 hours' do
      expect { subject }.to change { User.all.count }.by(-2)
    end
  end
end
