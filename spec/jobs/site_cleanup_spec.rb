# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteCleanupJob, type: :job do
  include ActiveJob::TestHelper

  let(:site_id) { rand() }

  subject { described_class.perform_now(site_id) }
  
  context 'when the site had no recordings' do
    it 'does not delete any recordings' do
      expect { subject }.not_to change { Recording.all.count }
    end
  end

  context 'when the site had recordings' do
    let!(:site) { create(:site) }
    let(:site_id) { site.id }

    before do
      # Three recordings from this site
      recording_1 = create(:recording, site_id:)
      recording_2 = create(:recording, site_id:)
      recording_3 = create(:recording, site_id:)
      # Three that are not
      recording_4 = create(:recording)
      recording_5 = create(:recording)
      recording_6 = create(:recording)
      # Three clicks that are for this site
      3.times { create(:click, site_id:) }
      # Three that are not
      3.times { create(:click) }
      # Three sets of events that are for this site
      3.times { create(:event, recording: recording_1) }
      3.times { create(:event, recording: recording_2) }
      3.times { create(:event, recording: recording_3) }
      # Three that are not
      3.times { create(:event, recording: recording_4) }
      3.times { create(:event, recording: recording_5) }
      3.times { create(:event, recording: recording_6) }

      # The site will have been destroyed by the time the
      # job runs
      site.destroy
    end

    it 'deletes the site data' do
      expect { subject }.to change { Recording.all.count }.by(-3)
                        .and change { Page.all.count }.by(-3)
                        .and change { Click.all.count }.by(-3)
                        .and change { Event.all.count }.by(-9)
    end
  end
end
