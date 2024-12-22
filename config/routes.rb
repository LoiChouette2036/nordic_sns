Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  root "pages#home"
  resource :profile, only: [ :new, :create, :edit, :update, :show ]
end
