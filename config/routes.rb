Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do      
      resources :users, only: [:index, :show] do
        member do
          get :followers
        end
      end

      resources :sleep_records, only: [:index] do
        collection do
          get :following_records
        end
      end

      resources :follows, only: [:index]
    end
  end
end
