# typed: false
# frozen_string_literal: true

require 'rails_helper'

admin_blog_post_update_mutation = <<-GRAPHQL
  mutation($input: AdminBlogPostUpdateInput!) {
    adminBlogPostUpdate(input: $input) {
      title
      category
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::BlogPostUpdate, type: :request do
  let(:user) { create(:user, superuser: true) }
  let!(:post) { create(:blog, title: 'Foo', category: 'Bar') }

  subject do
    variables = {
      input: {
        id: post.id,
        title: 'Baz',
        category: 'Zap'
      }
    }

    graphql_request(admin_blog_post_update_mutation, variables, user)
  end

  it 'updates the blog post' do
    subject
    post.reload
    expect(post.title).to eq('Baz')
    expect(post.category).to eq('Zap')
  end

  it 'returns the updated post' do
    response = subject['data']['adminBlogPostUpdate']
    expect(response).to eq('title' => 'Baz', 'category' => 'Zap')
  end
end
