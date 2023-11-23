# frozen_string_literal: true

require 'rails_helper'

site_session_settings_query = <<-GRAPHQL
  query($site_id: String!) {
    siteSessionSettings(siteId: $site_id) {
      name
      uuid
      cssSelectorBlacklist
      anonymiseFormInputs
      anonymiseText
      ingestEnabled
      ipBlacklist {
        name
        value
      }
      magicErasureEnabled
      invalidOrExceededPlan
      feedback {
        npsEnabled
        npsAccentColor
        npsSchedule
        npsPhrase
        npsFollowUpEnabled
        npsContactConsentEnabled
        npsLayout
        npsExcludedPages
        sentimentEnabled
        sentimentAccentColor
        sentimentExcludedPages
        sentimentLayout
        sentimentDevices
      }
      consent {
        name
        consentMethod
        layout
        privacyPolicyUrl
        languages
        languagesDefault
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::SiteSessionSettings, type: :request do
  let(:user) { nil }
  let!(:site) { create(:site) }
  let(:site_uuid) { site.uuid }

  subject do
    graphql_request(site_session_settings_query, { site_id: site_uuid }, user)
  end

  context 'when the site does not exist' do
    let(:site) { nil }
    let(:site_uuid) { SecureRandom.uuid }

    it 'returns nil' do
      expect(subject['data']['siteSessionSettings']).to eq nil
    end
  end

  context 'when the site has no selectors' do
    it 'returns an empty array' do
      expect(subject['data']['siteSessionSettings']['cssSelectorBlacklist']).to eq []
    end
  end

  context 'when the site has selectors' do
    let(:site) { create(:site, css_selector_blacklist: ['foo > bar', 'bar#baz']) }

    it 'returns the selectors' do
      expect(subject['data']['siteSessionSettings']['cssSelectorBlacklist']).to eq ['foo > bar', 'bar#baz']
    end
  end

  context 'when the site has forms anonymised' do
    let(:site) { create(:site, anonymise_form_inputs: true) }

    it 'returns the selectors' do
      expect(subject['data']['siteSessionSettings']['anonymiseFormInputs']).to eq true
    end
  end

  context 'when the site does not have forms anonymised' do
    let(:site) { create(:site, anonymise_form_inputs: false) }

    it 'returns the selectors' do
      expect(subject['data']['siteSessionSettings']['anonymiseFormInputs']).to eq false
    end
  end

  context 'when the site has no consent saved' do
    it 'does not return the consent' do
      expect(subject['data']['siteSessionSettings']['consent']).to eq nil
    end
  end

  context 'when the site has consent saved' do
    before do
      Consent.create(
        site:,
        name: 'Squeaky',
        consent_method: 'widget',
        layout: 'bottom_left',
        privacy_policy_url: 'https://squeaky.ai/privacy',
        languages: ['en'],
        languages_default: 'en'
      )
    end

    it 'returns the consent' do
      expect(subject['data']['siteSessionSettings']['consent']).to eq(
        'name' => 'Squeaky',
        'consentMethod' => 'widget',
        'layout' => 'bottom_left',
        'privacyPolicyUrl' => 'https://squeaky.ai/privacy',
        'languages' => ['en'],
        'languagesDefault' => 'en'
      )
    end
  end

  context 'when the site has no feedback saved' do
    it 'does not return the feedback' do
      expect(subject['data']['siteSessionSettings']['feedback']).to eq nil
    end
  end

  context 'when the site has feedback saved' do
    before { create(:feedback, site:) }

    it 'returns the feedback' do
      expect(subject['data']['siteSessionSettings']['feedback']).to eq(
        'npsAccentColor' => '#0074E0',
        'npsContactConsentEnabled' => false,
        'npsEnabled' => false,
        'npsFollowUpEnabled' => true,
        'npsLayout' => 'full_width',
        'npsPhrase' => 'My Feedback',
        'npsSchedule' => 'once',
        'npsExcludedPages' => [],
        'sentimentAccentColor' => '#0074E0',
        'sentimentEnabled' => false,
        'sentimentExcludedPages' => [],
        'sentimentLayout' => 'right_middle',
        'sentimentDevices' => %w[desktop tablet]
      )
    end
  end

  context 'when the magic erasure is enabled' do
    let(:site) { create(:site, magic_erasure_enabled: true) }

    context 'and they are not logged in' do
      it 'returns false for magic erasure enabled' do
        expect(subject['data']['siteSessionSettings']['magicErasureEnabled']).to eq(false)
      end
    end

    context 'and they are logged in as a user for another site' do
      let(:user) { create(:user) }

      it 'returns false for magic erasure enabled' do
        expect(subject['data']['siteSessionSettings']['magicErasureEnabled']).to eq(false)
      end
    end

    context 'and they are logged in as a user for this site but have a read only role' do
      let(:user) { create(:user) }

      before do
        create(:team, site:, user:, role: 0)
      end

      it 'returns false for magic erasure enabled' do
        expect(subject['data']['siteSessionSettings']['magicErasureEnabled']).to eq(false)
      end
    end

    context 'and they are logged in as a user for this site and have a read/write role' do
      let(:user) { create(:user) }

      before do
        create(:team, site:, user:, role: 1)
      end

      it 'returns true for magic erasure enabled' do
        expect(subject['data']['siteSessionSettings']['magicErasureEnabled']).to eq(true)
      end
    end
  end
end
