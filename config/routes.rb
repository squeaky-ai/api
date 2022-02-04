# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  scope 'api' do
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
        # GET /api/auth/current
        # -
        get 'current', to: 'auth/sessions#current'
        # POST /api/auth/sign_in
        # body: { "email": string, "password": string }
        post 'sign_in', to: 'auth/sessions#create', as: :user_session
        # POST /api/auth/sign_up
        # body: { "email": string, "password": string }
        post 'sign_up', to: 'auth/registrations#create', as: :user_registration
        # DELETE /api/auth/sign_out
        # -
        delete 'sign_out', to: 'auth/sessions#destroy', as: :destroy_user_session
        # POST /api/auth/confirm
        # body: { "email": string }
        post 'confirm', to: 'auth/confirmations#create', as: :user_confirmation
        # GET /api/auth/confirm
        # query: { "confirmation_token": string }
        get 'confirm', to: 'auth/confirmations#show'
        # POST /api/auth/reset_password
        # body: { "email": string }
        post 'reset_password', to: 'auth/passwords#create'
        # PUT /api/auth/change_password
        # body: { "password": string, "reset_password_token": string }
        put 'change_password', to: 'auth/passwords#update'
      end
    end
  end
end
