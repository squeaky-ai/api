# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphqlPlayground::Rails::Engine, at: '/api/playground', graphql_path: '/api/graphql'

  scope '/api' do
    get '/ping', to: 'ping#index'
    post '/graphql', to: 'graphql#execute'

    mount ActionCable.server => '/cable'
  end
end
