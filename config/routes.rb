# frozen_string_literal: true

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphqlPlayground::Rails::Engine, at: '/playground', graphql_path: '/api/graphql'
  end

  scope '/api' do
    get '/ping', to: 'ping#index'
    post '/graphql', to: 'graphql#execute'
  end
end
