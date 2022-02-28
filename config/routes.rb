# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  scope 'api', defaults: { format: :json } do
    get 'ping', to: 'ping#index'
    post 'graphql', to: 'graphql#execute'

    # Required to load devise
    devise_for :users, only: []

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
        # POST /api/auth/sign_up
        # body: { "email": string, "password": string }
        post 'sign_up', to: 'auth/registrations#create', as: :user_registration
        # DELETE /api/auth/sign_out
        # -
        delete 'sign_out', to: 'auth/sessions#destroy', as: :destroy_user_session
      end
    end
  end
end
