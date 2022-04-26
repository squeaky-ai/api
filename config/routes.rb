# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  scope 'api' do
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

    # These routes are designed for development e2e tests and
    # won't work in other environments
    post 'test/user', to: 'test#create_user'
    delete 'test/user', to: 'test#destroy_user'
  end

  root to: 'application#not_found'
  match '*anything', to: 'application#not_found', via: %i[get post]
end
