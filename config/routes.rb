Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  resources :agents, only: [ :index, :show, :update ]
  resources :organizations, only: [ :index, :show, :update ] do
    resource :budget, only: [ :update ]
  end
  resources :goals do
    member do
      post :transition
    end
  end

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

      resources :goals, only: [ :index ] do
        member do
          post :activate
        end
      end

      resources :agents, param: :token, only: [] do
        resource :ping, only: [ :create ]
        resource :budget_check, only: [ :show ], controller: "agent_budget_checks"
        resources :skills, only: [ :index, :show ], param: :name
      end
    end
  end
end
