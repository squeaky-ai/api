# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphqlPlayground::Rails::Engine, at: '/', graphql_path: '/api/graphql' # if Rails.env.development?

  scope '/api' do
    get '/ping', to: 'ping#index'
    post '/graphql', to: 'graphql#execute'

    mount ActionCable.server => '/cable'
  end
end
