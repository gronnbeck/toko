Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  resources :agents, only: [ :index, :show, :update ]
  resources :organizations, only: [ :index, :show, :update ]

  namespace :api do
    namespace :v1 do
      resources :tasks, only: [ :index ] do
        member do
          post :claim
          post :start
          post :complete
          post :fail
          post :report_cost
        end
        resources :messages, only: [ :index, :create ], controller: "task_messages"
        resource :relevance, only: [ :create ], controller: "task_relevances"
      end

      resources :agents, param: :token, only: [] do
        resource :ping, only: [ :create ]
      end
    end
  end
end
