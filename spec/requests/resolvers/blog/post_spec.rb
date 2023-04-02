# frozen_string_literal: true

require 'rails_helper'

blog_post_query = <<-GRAPHQL
  query($slug: String!) {
    blogPost(slug: $slug) {
      title
      tags
      author {
        name
        image
      }
      category
      draft
      metaImage
      metaDescription
      slug
      body
      createdAt {
        iso8601
      }
      updatedAt {
        iso8601
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Blog::Post, type: :request do
  context 'when the post does not exist' do
    subject do
      variables = {
        slug: '/foo/bar'
      }

      graphql_request(blog_post_query, variables, nil)
    end

    it 'returns nil' do
      response = subject['data']['blogPost']
      expect(response).to eq(nil)
    end
  end

  context 'when the post exists but it is a draft and there is no user' do
    before do
      create(:blog, slug: '/foo/bar', draft: true)
    end

    subject do
      variables = {
        slug: '/foo/bar'
      }

      graphql_request(blog_post_query, variables, nil)
    end

    it 'returns nil' do
      response = subject['data']['blogPost']
      expect(response).to eq(nil)
    end
  end

  context 'when the post exists but it is a draft and there is a user but they are not a super user' do
    let(:user) { create(:user) }

    before do
      create(:blog, slug: '/foo/bar', draft: true)
    end

    subject do
      variables = {
        slug: '/foo/bar'
      }

      graphql_request(blog_post_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['blogPost']
      expect(response).to eq(nil)
    end
  end

  context 'when the post exists but it is a draft and there is a user and they are a super user' do
    let(:user) { create(:user, superuser: true) }

    before do
      create(:blog, slug: '/foo/bar', draft: true)
    end

    subject do
      variables = {
        slug: '/foo/bar'
      }

      graphql_request(blog_post_query, variables, user)
    end

    it 'returns the post' do
      response = subject['data']['blogPost']
      expect(response).to_not eq(nil)
    end
  end

  context 'when the post exists and it is not a draft' do
    before do
      create(:blog, slug: '/foo/bar')
    end

    subject do
      variables = {
        slug: '/foo/bar'
      }

      graphql_request(blog_post_query, variables, nil)
    end

    it 'returns the post' do
      response = subject['data']['blogPost']
      expect(response).to_not eq(nil)
    end
  end
end