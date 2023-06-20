# frozen_string_literal: true

require 'rails_helper'

admin_changelog_post_update_mutation = <<-GRAPHQL
  mutation($input: AdminChangelogPostUpdateInput!) {
    adminChangelogPostUpdate(input: $input) {
      title
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::ChangelogPostUpdate, type: :request do
  let(:user) { create(:user, superuser: true) }
  let!(:post) { create(:changelog, title: 'Foo') }

  subject do
    variables = {
      input: {
        id: post.id,
        title: 'Baz'
      }
    }

    graphql_request(admin_changelog_post_update_mutation, variables, user)
  end

  it 'updates the changelog post' do
    subject
    post.reload
    expect(post.title).to eq('Baz')
  end

  it 'returns the updated post' do
    response = subject['data']['adminChangelogPostUpdate']
    expect(response).to eq('title' => 'Baz')
  end
end
