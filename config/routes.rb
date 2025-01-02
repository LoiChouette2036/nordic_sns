Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  root "pages#home"
  resource :profile, only: [ :new, :create, :edit, :update, :show ]
  resources :posts, only: [ :index, :create, :show ] do
    resources :likes, only: [ :create, :destroy ], shallow: true
  end
  resources :conversations do
    member do
      patch :accept
    end
    resources :messages, only: :create
  end

  # Add search route for users
  get "/users/search", to: "users#search"

  get "/test_turbo_stream", to: "profiles#test_turbo_stream"

  get "test_broadcast", to: "profiles#test_broadcast"
end
