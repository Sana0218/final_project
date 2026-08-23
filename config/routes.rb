# frozen_string_literal: true

Rails.application.routes.draw do
  root 'static_pages#top'

  # User registration
  resources :users, only: %i[new create]

  # Login / Logout
  get 'login' => 'user_sessions#new', as: :login
  post 'login' => 'user_sessions#create'
  delete 'logout' => 'user_sessions#destroy', as: :logout

  # profile / account editing
  resource :profile, only: %i[show edit update]

  # reviews
  resources :reviews, only: [:index] do
    member do
      post :complete
    end
  end

  # saved phrases
  resources :phrases, only: [:index]

  # diaries
  resources :diaries, only: %i[index show new create] do
    member do
      post :save_phrases
    end
  end
end
