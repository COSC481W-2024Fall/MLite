Rails.application.routes.draw do
  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users
  devise_scope :user do
    get 'users/sign_out', to: 'devise/sessions#destroy'
  end
  resources :datasets
  resources :models do
    member do
      post :deploy
      post :upload_file
    end
  end
  resources :deployments do
    member do
      get :inference
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"


  # Route for inference page

  get 'deployments/:id/inference', to: 'deployments#inference', as: 'deployment_inference'
  post 'deployments/:id/inference', to: 'deployments#do_inference'

  get 'deployments/:id/inference/result', to: 'deployments#inference_result', as: 'deployment_inference_result'
end
