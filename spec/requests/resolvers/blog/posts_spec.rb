# frozen_string_literal: true

require 'rails_helper'

blog_posts_query = <<-GRAPHQL
  query($category: String, $tags: [String!]!) {
    blogPosts(category: $category, tags: $tags) {
      categories
      tags
      posts {
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
        createdAt
        updatedAt
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Blog::Posts, type: :request do
  context 'when there are no posts' do
    subject do
      variables = {
        category: nil,
        tags: []
      }

      graphql_request(blog_posts_query, variables, nil)
    end

    it 'returns the empty state' do
      response = subject['data']['blogPosts']
      expect(response).to eq(
        'categories' => [],
        'tags' => [],
        'posts' => []
      )
    end
  end

  context 'when there are some posts' do
    before do
      create(:blog, category: 'Category 1', tags: ['Tag 1', 'Tag 2'])
      create(:blog, category: 'Category 2', tags: ['Tag 2', 'Tag 3'])
    end

    subject do
      variables = {
        category: nil,
        tags: []
      }

      graphql_request(blog_posts_query, variables, nil)
    end

    it 'returns the posts' do
      response = subject['data']['blogPosts']
      expect(response['categories']).to match_array(['Category 1', 'Category 2'])
      expect(response['tags']).to match_array(['Tag 1', 'Tag 2', 'Tag 3'])
      expect(response['posts']).to match_array([
        {
          'author' =>  {
            'image' =>  'https://cdn.squeaky.ai/blog/lewis.jpg', 
            'name' => 'Lewis Monteith'
          }, 
          'body' => 'Hello world', 
          'category' => 'Category 1', 
          'draft' => false, 
          'metaDescription' => 'Meta Description', 
          'metaImage' => 'https://cdn.squeaky.ai/image.png', 
          'slug' => '/category/title', 
          'tags' => ['Tag 1', 'Tag 2'], 
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
          'category' => 'Category 2', 
          'draft' => false, 
          'metaDescription' => 'Meta Description', 
          'metaImage' => 'https://cdn.squeaky.ai/image.png', 
          'slug' => '/category/title', 
          'tags' => ['Tag 2', 'Tag 3'], 
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
        create(:blog, draft: true)
      end
  
      subject do
        variables = {
          category: nil,
          tags: []
        }
  
        graphql_request(blog_posts_query, variables, nil)
      end

      it 'does not return the post' do
        response = subject['data']['blogPosts']
        expect(response['posts']).to eq([])
      end
    end

    context 'and the logged in user is not a superuser' do
      let(:user) { create(:user) }

      before do
        create(:blog, draft: true)
      end
  
      subject do
        variables = {
          category: nil,
          tags: []
        }
  
        graphql_request(blog_posts_query, variables, user)
      end

      it 'does not return the post' do
        response = subject['data']['blogPosts']
        expect(response['posts']).to eq([])
      end
    end

    context 'and the logged in user is a superuser' do
      let(:user) { create(:user, superuser: true) }

      before do
        create(:blog, draft: true)
      end
  
      subject do
        variables = {
          category: nil,
          tags: []
        }
  
        graphql_request(blog_posts_query, variables, user)
      end

      it 'does returns the post' do
        response = subject['data']['blogPosts']
        expect(response['posts']).to match_array([
          {
            'author' => {
              'image' => 'https://cdn.squeaky.ai/blog/lewis.jpg',
              'name' => 'Lewis Monteith'
            },
            'body' => 'Hello world',
            'category' => 'Category',
            'draft' => true,
            'metaDescription' => 'Meta Description',
            'metaImage' => 'https://cdn.squeaky.ai/image.png',
            'slug' => '/category/title',
            'tags' => ['Tag 1', 'Tag 2'],
            'title' => 'Title',
            'createdAt' => anything,
            'updatedAt' => anything
          }
        ])
      end
    end
  end

  context 'when a category is given' do
    before do
      create(:blog, category: 'Category 1')
      create(:blog, category: 'Category 2')
    end

    subject do
      variables = {
        category: 'Category 1',
        tags: []
      }

      graphql_request(blog_posts_query, variables, nil)
    end

    it 'only returns posts with that category' do
      response = subject['data']['blogPosts']
      categories = response['posts'].map { |post| post['category'] }

      expect(response['posts'].size).to eq(1)
      expect(categories).to eq(['Category 1'])
    end
  end

  context 'when tags are given' do
    before do
      create(:blog, tags: ['Tag 1'])
      create(:blog, tags: ['Tag 2'])
    end

    subject do
      variables = {
        category: nil,
        tags: ['Tag 1']
      }

      graphql_request(blog_posts_query, variables, nil)
    end

    it 'only returns posts that have those tags' do
      response = subject['data']['blogPosts']
      tags = response['posts'].map { |post| post['tags'] }.flatten

      expect(response['posts'].size).to eq(1)
      expect(tags).to eq(['Tag 1'])
    end
  end

  context 'when a mixture is given' do
    before do
      create(:blog, tags: ['Tag 1', 'Tag 2'], category: 'Category 1')
      create(:blog, tags: ['Tag 2', 'Tag 3'], category: 'Category 2')
      create(:blog, tags: ['Tag 1', 'Tag 3'], category: 'Category 3')
    end

    subject do
      variables = {
        category: 'Category 1',
        tags: ['Tag 1', 'Tag 2']
      }

      graphql_request(blog_posts_query, variables, nil)
    end

    it 'only returns posts that have those tags and category' do
      response = subject['data']['blogPosts']
      category = response['posts'].map { |post| post['category'] }.uniq
      tags = response['posts'].map { |post| post['tags'] }.flatten

      expect(response['posts'].size).to eq(1)
      expect(tags).to eq(['Tag 1', 'Tag 2'])
    end
  end
end
