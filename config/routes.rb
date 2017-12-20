# frozen_string_literal: true

Rails.application.routes.draw do
  root 'incidents#index'

  devise_for :users, skip: :registrations
  devise_scope :user do
    get 'users/change_password' => 'devise/registrations#edit', as: :change_password
    patch 'users/:id' => 'devise/registrations#update', as: :user_registration
  end

  resources :incidents do
    collection do
      get  :incomplete
      get  :search
      get  :unclaimed
      get  :unreviewed
    end
    member do
      post :claim
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
