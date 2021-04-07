# frozen_string_literal: true

Rails.application.routes.draw do
  root 'incidents#index'

  devise_for :users, skip: :registrations
  devise_scope :user do
    get 'users/change_password' => 'users/registrations#edit', as: :change_password
    patch 'users/:id' => 'users/registrations#update', as: :user_registration
  end

  if Rails.env.development?
    post '/dev_login', to: 'dev_login#create', as: 'dev_login'
  end

  resources :incidents do
    collection do
      get  :batch_hastus_export
      get  :incomplete
      get  :search
      get  :unclaimed
      get  :unreviewed
    end
    member do
      post :claim
      post :claims_export
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
        post :reset_password
      end
    end
  end
end
