Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do      
      get "health" => "health#index"

      resources :users, only: [:index, :create, :show] do
        member do
          get :followers
        end
      end
      
      resources :sleep_records, only: [:index, :create, :update] do
        collection do
          get :following_records
        end
      end
      
      resources :follows, only: [:create, :destroy, :index]
    end
  end
end
