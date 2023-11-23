# frozen_string_literal: true

require 'rails_helper'

changelog_viewed_mutation = <<-GRAPHQL
  mutation($input: UserChangelogViewedInput!) {
    usersChangelogViewed(input: $input) {
      id
      changelogLastViewedAt {
        iso8601
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Users::ChangelogViewed, type: :request do
  let(:now) { Time.current }
  let(:user) { create(:user) }

  before do
    allow(Time).to receive(:current).and_return(now)
  end

  subject do
    variables = { input: {} }
    graphql_request(changelog_viewed_mutation, variables, user)
  end

  it 'returns the updated timestamp' do
    response = subject['data']['usersChangelogViewed']
    expect(response['changelogLastViewedAt']).to eq(
      'iso8601' => now.iso8601
    )
  end

  it 'updates the user record' do
    expect { subject }.to change { user.changelog_last_viewed_at }.from(nil).to(now)
  end

  context 'when the date is already set' do
    let(:user) { create(:user, changelog_last_viewed_at: now - 10.minutes) }

    it 'returns the updated timestamp' do
      response = subject['data']['usersChangelogViewed']
      expect(response['changelogLastViewedAt']).to eq(
        'iso8601' => now.iso8601
      )
    end

    it 'updates the user record' do
      expect { subject }.to change { user.changelog_last_viewed_at }.from(now - 10.minutes).to(now)
    end
  end
end
