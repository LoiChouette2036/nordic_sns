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
  resources :products do
    member do
      post :create_checkout_session
    end
  end
  resources :orders, only: [ :index, :show, :create ]

  get "checkout/success", to: "checkout#success", as: "checkout_success"
  get "checkout/cancel", to: "checkout#cancel", as: "checkout_cancel"

  post "/webhooks/stripe", to: "webhook#stripe"
end
