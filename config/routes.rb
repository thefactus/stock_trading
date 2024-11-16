Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/docs", to: "docs#show"
  get "/docs/openapi.yml", to: "docs#openapi"

  namespace :api do
    namespace :v1 do
      devise_for :users,
        defaults: { format: :json },
        controllers: {
          registrations: "api/v1/users/registrations"
        }

      namespace :buyers do
        resources :businesses, only: [:index] do
          resources :buy_orders, only: [:create], controller: 'buy_orders'
          resources :purchases, only: [:index], controller: 'purchases'
        end
      end

      namespace :owners do
        resources :businesses, only: [:index] do
          resources :buy_orders, only: [:index, :update]
        end
      end
    end
  end

  # Defines the root path route ("/")
  root "docs#show"
end
