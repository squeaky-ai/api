# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

admin_blog_post_create_mutation = <<-GRAPHQL
  mutation($input: AdminBlogPostCreateInput!) {
    adminBlogPostCreate(input: $input) {
      title
      body
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::BlogPostCreate, type: :request do
  let(:user) { create(:user, superuser: true) }

  subject do
    variables = {
      input: {
        title: 'Hello',
        category: 'Category',
        tags: ['Tag 1', 'Tag 2'],
        author: 'lewis',
        draft: true,
        metaImage: 'https://cdn.squeaky.ai/blog/cat-in-space.jpg',
        metaDescription: 'Meta',
        slug: '/category/hello',
        body: 'Hello',
        createdAt: Time.now.iso8601,
        updatedAt: Time.now.iso8601
      }
    }

    graphql_request(admin_blog_post_create_mutation, variables, user)
  end

  it 'creates the blog post' do
    subject
    expect(Blog.find_by(title: 'Hello')).not_to eq(nil)
  end

  it 'returns the post' do
    response = subject['data']['adminBlogPostCreate']
    expect(response).to eq('title' => 'Hello', 'body' => 'Hello')
  end
end
