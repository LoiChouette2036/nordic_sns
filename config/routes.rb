Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  root "pages#home"
  resource :profile, only: [ :new, :create, :edit, :update, :show ]
  resources :posts, only: [ :index, :create, :show ] do
    resources :likes, only: [ :create, :destroy ]
  end
  resources :conversations do
    member do
      patch :accept
    end
    resources :messages, only: :create
  end
  resources :products
end
