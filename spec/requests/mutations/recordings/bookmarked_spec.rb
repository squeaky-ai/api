# frozen_string_literal: true

require 'rails_helper'

recording_bookmarked_mutation = <<-GRAPHQL
  mutation($input: RecordingsBookmarkedInput!) {
    recordingBookmarked(input: $input) {
      id
      bookmarked
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::Bookmarked, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingId: 234234, 
          bookmarked: false 
        }
      }
      graphql_request(recording_bookmarked_mutation, variables, user)
    end

    it 'throws an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording does exist' do
    context 'and it is bookmarked' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:recording) { create(:recording, site: site) }

      before do
        ClickHouse::Recording.insert do |buffer|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: recording.id
          }
        end
      end

      subject do
        variables = {
          input: { 
            siteId: site.id,
            recordingId: recording.id,
            bookmarked: true 
          }
        }
        graphql_request(recording_bookmarked_mutation, variables, user)
      end

      it 'marks the site as bookmarked' do
        response = subject['data']['recordingBookmarked']
        expect(response['bookmarked']).to be true
      end

      it 'updates the recording in the database' do
        expect { subject }.to change { Recording.find_by(id: recording.id).bookmarked }.from(false).to(true)
      end

      it 'updates the clickhouse record' do
        subject
        result = Sql::ClickHouse.select_one("SELECT bookmarked FROM recordings WHERE recording_id = #{recording.id}")
        expect(result).to eq('bookmarked' => true)
      end
    end

    context 'and it is unbookmarked' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:recording) { create(:recording, bookmarked: true, site: site) }

      before do
        ClickHouse::Recording.insert do |buffer|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: recording.id
          }
        end
      end

      subject do
        variables = {
          input: {
            siteId: site.id, 
            recordingId: recording.id, 
            bookmarked: false
          }
        }
        graphql_request(recording_bookmarked_mutation, variables, user)
      end

      it 'marks the site as unbookmarked' do
        response = subject['data']['recordingBookmarked']
        expect(response['bookmarked']).to be false
      end

      it 'updates the recording in the database' do
        expect { subject }.to change { Recording.find_by(id: recording.id).bookmarked }.from(true).to(false)
      end

      it 'updates the clickhouse record' do
        subject
        result = Sql::ClickHouse.select_one("SELECT bookmarked FROM recordings WHERE recording_id = #{recording.id}")
        expect(result).to eq('bookmarked' => false)
      end
    end
  end
end
