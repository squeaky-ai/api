# frozen_string_literal: true

require 'rails_helper'

admin_changelog_post_create_mutation = <<-GRAPHQL
  mutation($input: AdminChangelogPostCreateInput!) {
    adminChangelogPostCreate(input: $input) {
      title
      body
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::ChangelogPostCreate, type: :request do
  let(:user) { create(:user, superuser: true) }

  subject do
    variables = {
      input: {
        title: 'Hello',
        author: 'lewis',
        draft: true,
        metaImage: 'https://cdn.squeaky.ai/blog/cat-in-space.jpg',
        metaDescription: 'Meta',
        slug: '/category/hello',
        body: 'Hello'
      }
    }

    graphql_request(admin_changelog_post_create_mutation, variables, user)
  end

  it 'creates the changelog post' do
    subject
    expect(Changelog.find_by(title: 'Hello')).not_to eq(nil)
  end

  it 'returns the post' do
    response = subject['data']['adminChangelogPostCreate']
    expect(response).to eq('title' => 'Hello', 'body' => 'Hello')
  end
end
