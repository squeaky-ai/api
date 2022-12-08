# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  scope 'api' do # rubocop:disable Metrics/BlockLength
    # Ping endpoint for the ALB to check health
    get 'ping', to: 'ping#index'

    # GraphQL endpoint
    post 'graphql', to: 'graphql#execute'

    # Required to load devise
    devise_for :users, only: []

    # Sidekiq dashboard and GraphQL playground
    # are only for superusers
    authenticate :user, ->(u) { u.superuser? } do
      mount Sidekiq::Web => '/sidekiq'
      mount GraphqlPlayground::Rails::Engine, at: 'playground', graphql_path: 'graphql'
    end

    namespace :webhooks do
      post 'stripe', to: 'stripe#index'
    end

    resources :invoices, only: [:show]

    resources :sites do
      get '/heatmaps/cursors', to: 'sites/heatmaps#cursors'
      get '/heatmaps/click_counts', to: 'sites/heatmaps#click_counts'
      get '/heatmaps/click_positions', to: 'sites/heatmaps#click_positions'
      get '/heatmaps/scrolls', to: 'sites/heatmaps#scrolls'
    end

    # Custom devise routes that are more suited to the front end
    scope 'auth' do
      devise_scope :user do
        # POST /api/auth/sign_in
        # body: { "email": string, "password": string }
        post 'sign_in', to: 'auth/sessions#create', as: :user_session
        # DELETE /api/auth/sign_out
        # -
        delete 'sign_out', to: 'auth/sessions#destroy', as: :destroy_user_session
      end
    end

    scope 'integrations' do
      scope 'websitebuilder', as: 'duda' do # they do not allow you to have the word duda in there
        post 'install', to: 'integrations/duda#install'
        post 'uninstall', to: 'integrations/duda#uninstall'
        post 'change_plan', to: 'integrations/duda#change_plan'
        get 'sso', to: 'integrations/duda#sso'
        post 'webhook', to: 'integrations/duda#webhook'
      end
    end
  end

  root to: 'application#not_found'
  # match '*anything', to: 'application#not_found', via: %i[get post]
end
