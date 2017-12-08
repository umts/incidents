# frozen_string_literal: true

Rails.application.routes.draw do
  root 'incidents#index'
  resources :incidents do
    collection do
      get  :incomplete
      get  :search
      get  :unreviewed
    end
    member do
      get  :history
    end
  end

  resources :incident_reports, only: %i[edit update] do
    member do
      get  :history
    end
  end

  resources :staff_reviews, only: %i[create destroy update]

  resources :supervisor_reports, only: %i[edit update] do
    member do
      get  :history
    end
  end

  scope :staff do
    resources :users, except: :show do
      collection do
        get  :import
        post :import
      end
      member do
        post :deactivate
        get  :incidents
        post :reactivate
      end
    end
  end

  get 'sessions/login', to: 'sessions#login',
                        as: :login
  post 'sessions/login', to: 'sessions#login'
  delete 'sessions/destroy', to: 'sessions#destroy',
                             as: :destroy_session
end
