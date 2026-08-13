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
end