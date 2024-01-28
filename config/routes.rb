Rails.application.routes.draw do
  resources :energies do
    collection { post :import_enphase }
    collection { post :import_edison }
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Needed for simple_form_for to select date
  resources :hour_by_hours, only: [:index, :show]
  resources :day_by_days, only: [:index, :show]
  resources :month_by_months, only: [:index, :show]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  get "monthly", to: 'energies#monthly'  
  get "daily", to: 'energies#daily'
  get "hourly", to: 'energies#hourly'
  
  # Defines the root path route ("/")
  root "energies#index"
end
