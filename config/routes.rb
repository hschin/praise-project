Rails.application.routes.draw do
  devise_for :users

  root "home#index"
  get "app", to: "decks#index", as: :app

  resources :decks do
    collection do
      post :quick_create
    end
    member do
      post :export
      get :download_export
    end
    resources :deck_songs, only: [ :create, :update, :destroy ] do
      member do
        patch :reorder
        patch :update_arrangement
      end
    end
    resources :themes, only: [ :create ] do
      collection do
        post :suggest
      end
    end
  end

  resources :songs do
    collection do
      post :import
      get :select
      post :confirm_import
      get :processing
    end
  end

  get  "admin"           => "admin#index",  as: :admin
  get  "admin/decks"     => "admin#decks",  as: :admin_decks
  get  "admin/decks/:id" => "admin#deck",   as: :admin_deck

  patch "locale", to: "locales#update", as: :locale

  get "up" => "rails/health#show", as: :rails_health_check

  # Rich health check — used by ALB health check target and external monitors
  get "health" => "health#show", as: :health_check
end
