Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: "lines#index"

  resources :lines, only: [:index]
  get "/routes/:code/stats", to: "routes#stats", as: "route_stats"
  resources :reports, only: [:index] do
    collection do
      get :estimated_coverage
      get :daily_vs_normal
      get :vehicles
      get :vehicle_count
      get :stops
    end
  end
  resources :about, only: [:index]

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
