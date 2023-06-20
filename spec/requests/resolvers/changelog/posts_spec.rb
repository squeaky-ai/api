# frozen_string_literal: true

require 'rails_helper'

changelog_posts_query = <<-GRAPHQL
  query {
    changelogPosts {
      title
      author {
        name
        image
      }
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

RSpec.describe Resolvers::Changelog::Posts, type: :request do
  context 'when there are no posts' do
    subject do
      graphql_request(changelog_posts_query, {}, nil)
    end

    it 'returns the empty state' do
      response = subject['data']['changelogPosts']
      expect(response).to eq([])
    end
  end

  context 'when there are some posts' do
    before do
      create(:changelog)
      create(:changelog)
    end

    subject do
      graphql_request(changelog_posts_query, {}, nil)
    end

    it 'returns the posts' do
      response = subject['data']['changelogPosts']
      expect(response).to match_array([
        {
          'author' =>  {
            'image' =>  'https://cdn.squeaky.ai/blog/lewis.jpg', 
            'name' => 'Lewis Monteith'
          }, 
          'body' => 'Hello world', 
          'draft' => false, 
          'metaDescription' => 'Meta Description', 
          'metaImage' => 'https://cdn.squeaky.ai/image.png', 
          'slug' => '/category/title', 
          'title' => 'Title', 
          'createdAt' => anything, 
          'updatedAt' => anything
        }, 
        {
          'author' => {
            'image' => 'https://cdn.squeaky.ai/blog/lewis.jpg', 
            'name' => 'Lewis Monteith'
          }, 
          'body' => 'Hello world', 
          'draft' => false, 
          'metaDescription' => 'Meta Description', 
          'metaImage' => 'https://cdn.squeaky.ai/image.png', 
          'slug' => '/category/title', 
          'title' => 'Title', 
          'createdAt' => anything,
          'updatedAt' => anything
        }
      ])
    end
  end

  context 'when a post is a draft' do
    context 'and no one is logged in' do
      before do
        create(:changelog, draft: true)
      end
  
      subject do  
        graphql_request(changelog_posts_query, {}, nil)
      end

      it 'does not return the post' do
        response = subject['data']['changelogPosts']
        expect(response).to eq([])
      end
    end

    context 'and the logged in user is not a superuser' do
      let(:user) { create(:user) }

      before do
        create(:changelog, draft: true)
      end
  
      subject do  
        graphql_request(changelog_posts_query, {}, user)
      end

      it 'does not return the post' do
        response = subject['data']['changelogPosts']
        expect(response).to eq([])
      end
    end

    context 'and the logged in user is a superuser' do
      let(:user) { create(:user, superuser: true) }

      before do
        create(:changelog, draft: true)
      end
  
      subject do  
        graphql_request(changelog_posts_query, {}, user)
      end

      it 'does returns the post' do
        response = subject['data']['changelogPosts']
        expect(response).to match_array([
          {
            'author' => {
              'image' => 'https://cdn.squeaky.ai/blog/lewis.jpg',
              'name' => 'Lewis Monteith'
            },
            'body' => 'Hello world',
            'draft' => true,
            'metaDescription' => 'Meta Description',
            'metaImage' => 'https://cdn.squeaky.ai/image.png',
            'slug' => '/category/title',
            'title' => 'Title',
            'createdAt' => anything,
            'updatedAt' => anything
          }
        ])
      end
    end
  end
end
