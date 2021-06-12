# frozen_string_literal: true

Rails.application.routes.draw do
  scope 'api' do
    get 'ping', to: 'ping#index'
    post 'graphql', to: 'graphql#execute'

    # Enable the GraphQL playground
    mount GraphqlPlayground::Rails::Engine, at: 'playground', graphql_path: 'graphql'

    # Custom devise routes that are more suited to the front end
    scope 'auth' do
      devise_scope :user do
        post 'sign_in', to: 'auth/sessions#create', as: :user_session
        post 'sign_up', to: 'auth/registrations#create', as: :user_registration
        delete 'sign_out', to: 'auth/sessions#destroy', as: :destroy_user_session
        post 'confirm', to: 'auth/confirmations#create', as: :user_confirmation
      end
    end
  end
end
