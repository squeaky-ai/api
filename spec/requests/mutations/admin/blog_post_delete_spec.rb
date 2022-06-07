# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

admin_blog_post_delete_mutation = <<-GRAPHQL
  mutation($input: AdminBlogPostDeleteInput!) {
    adminBlogPostDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::BlogPostDelete, type: :request do
  context 'when the post does not exist' do
    let(:user) { create(:user, superuser: true) }

    subject do
      variables = {
        input: {
          id: 'dfsgdgfgdfgdfgdfg'
        }
      }

      graphql_request(admin_blog_post_delete_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['adminBlogPostDelete']
      expect(response).to eq(nil)
    end
  end

  context 'when the post exists' do
    let(:user) { create(:user, superuser: true) }
    let!(:post) { create(:blog) }

    subject do
      variables = {
        input: {
          id: post.id
        }
      }

      graphql_request(admin_blog_post_delete_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['adminBlogPostDelete']
      expect(response).to eq(nil)
    end

    it 'deletes the post' do
      expect { subject }.to change { Blog.find_by(id: post.id).nil? }.from(false).to(true)
    end
  end
end
