# frozen_string_literal: true

Rails.application.routes.draw do
  # Lightweight health check for Render keep-alive / uptime monitors (no login).
  get 'up' => 'rails/health#show', as: :rails_health_check

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
  resources :reviews, only: %i[index create] do
    member do
      post :complete
    end
  end

  # saved phrases
  resources :phrases, only: [:index]

  # Calendar for scheduled reviews
  resource :review_calendar, only: [:show]

  # diaries
  resources :diaries, only: %i[index show new create] do
    member do
      post :save_phrases
    end
  end
end
