Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  resources :agents, only: [ :index, :show, :update ]

  namespace :api do
    namespace :v1 do
      resources :tasks, only: [ :index ] do
        member do
          post :claim
          post :complete
          post :fail
        end
      end
    end
  end
end
