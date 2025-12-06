Rails.application.routes.draw do
  root "pages#home"

  resources :events, only: [ :new, :create, :show ] do
    member do
      get :organize
      get :dashboard
      post :draw_assignments
      post :launch
      post :send_reminder
    end

    resource :settings, controller: "event_settings", only: [ :edit, :update ]
    resources :participants, only: [ :create, :destroy ]
  end

  resources :wishlist_items, only: [ :index, :create, :destroy ]

  # Authentication routes using magic links
  resource :session, only: [ :new, :create, :destroy ] do
    post :select_event, on: :collection
  end
  get "auth/:token", to: "sessions#authenticate", as: :auth

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
