Rails.application.routes.draw do
  devise_for :users

  root "decks#index"

  resources :decks do
    collection do
      post :quick_create
    end
    member do
      post :export
      get :download_export
    end
    resources :deck_songs, only: [:create, :update, :destroy] do
      member do
        patch :reorder
        patch :update_arrangement
      end
    end
    resources :themes, only: [:create] do
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

  get "up" => "rails/health#show", as: :rails_health_check
end
