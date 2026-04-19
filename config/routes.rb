Rails.application.routes.draw do
  # ActiveStorage routes
  mount ActiveStorage::Engine => "/rails/active_storage"

  devise_for :users
  root 'dashboard#index'

  # Error pages
  get '/404', to: 'errors#not_found', as: :not_found
  get '/422', to: 'errors#unprocessable_entity', as: :unprocessable_entity
  get '/500', to: 'errors#internal_server_error', as: :internal_server_error

  resources :properties
  resources :projects do
    resources :properties, except: [:index]

    resources :leads do
      member { patch :update_stage }
      resources :activities, only: [:create, :destroy]
    end
    resource :construction_site, only: [:show, :edit, :update] do
      resources :milestones do
        resources :construction_tasks
        resources :site_documents
      end
      resources :workers do
        resources :work_logs, only: [:index, :create]
      end
      resources :materials
    end
  end

  namespace :admin do
    resources :users
    get :reports, to: 'reports#index'
  end
end
