Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  ALLOWED_FORMATS = %i[json kml gpx acmi].freeze

  # backend routes handled by Rails
  constraints(->(req) { ALLOWED_FORMATS.include?(req.format.symbol) }) do
    devise_for :users, skip: %i[sessions registrations]
    devise_scope :user do
      post 'login' => 'sessions#create'
      delete 'logout' => 'sessions#destroy'
      post 'signup' => 'registrations#create'
      delete 'signup' => 'registrations#destroy'
      patch 'signup' => 'registrations#update'
      put 'signup' => 'registrations#update'
    end

    resources :aircraft, only: %i[index show create update destroy] do
      resources :flights, only: %i[index show], controller: 'aircraft/flights'
      resources :telemetry, only: :index do
        collection { get :boundaries }
      end
      resources :uploads, only: %i[index create]
      resources :users, only: [] do
        resource :permission, only: %i[update destroy], constraints: {user_id: /[^\/]+/}
      end
    end
    resources :flights, only: %i[show]
  end
  
    if Rails.env.development?
      require 'sidekiq/web'
      mount Sidekiq::Web => 'sidekiq'
    end

  # SPA endpoint
  root 'home#index'

  # front-end routes handled by Vue-Router (routes.js)
  constraints(->(req) { req.format == '*/*' || req.format.html? }) do # TODO: .all? doesn't work here
    get 'aircraft' => 'home#index'
    get 'aircraft/:id' => 'home#index'
    get 'aircraft/:aircraft_id/flights/:id' => 'home#index'
    get 'flights/:token' => 'home#index'
  end
end
