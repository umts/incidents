# frozen_string_literal: true

Rails.application.routes.draw do
  root 'incidents#index'
  resources :incidents do
    collection do
      get  :incomplete
      get  :unreviewed
    end
    member do
      get  :history
    end
  end

  resources :incident_reports, only: %i[edit update]

  resources :staff_reviews, only: %i[create destroy update]

  scope :staff do
    resources :users, except: :show do
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
