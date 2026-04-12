Rails.application.routes.draw do
  devise_for :users
  resources :properties, only: [:index]
  root 'dashboard#index'

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
