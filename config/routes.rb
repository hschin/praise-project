Rails.application.routes.draw do
  devise_for :users

  root "decks#index"

  resources :decks do
    member do
      post :export
    end
    resources :deck_songs, only: [:create, :update, :destroy] do
      member do
        patch :reorder
        patch :update_arrangement
      end
    end
    resources :themes, only: [:create]
  end

  resources :songs do
    collection do
      post :import
      get :processing
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
