Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  root "dashboard#index"
  get "dashboard", to: "dashboard#index", as: :dashboard
  get "map", to: "maps#show", as: :map

  resources :families, only: [ :index, :new, :create, :show ] do
    resources :family_memberships, only: [ :create, :destroy ]
  end

  resources :tree_entries
  resources :season_goals, only: [ :update, :edit ]
  resources :locations, only: [ :update, :destroy ] do
    get :nearby, on: :collection
    member do
      patch :hide
      patch :unhide
    end
  end


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
