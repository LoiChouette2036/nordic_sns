Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  root "pages#home"
  resource :profile, only: [ :new, :create, :edit, :update, :show ]
  resources :posts, only: [ :index, :create, :show ]
  resources :conversations

  # Add search route for users
  get "/users/search", to: "users#search"
end
