# frozen_string_literal: true

Rails.application.routes.draw do
  # Enable the GraphQL playground
  mount GraphqlPlayground::Rails::Engine,
        at: '/api/playground',
        graphql_path: '/api/graphql'

  scope '/api' do
    get '/ping', to: 'ping#index'
    post '/graphql', to: 'graphql#execute'

    # Override the devise controllers so that they
    # only respond to json
    # devise_for :users, controllers: {
    #   sessions: 'auth/sessions',
    #   registrations: 'auth/registrations'
    # }

    scope '/auth' do
      devise_scope :user do
        post 'sign_in', to: 'auth/sessions#create', as: :user_session
        post 'sign_up', to: 'auth/registrations#create', as: :user_registration
        delete 'sign_out', to: 'auth/sessions#destroy', as: :destroy_user_session
        post 'confirm', to: 'auth/confirmations#create', as: :user_confirmation
      end
    end
  end
end
