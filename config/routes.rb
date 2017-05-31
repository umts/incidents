# frozen_string_literal: true

Rails.application.routes.draw do
  root 'incidents#index'
  resources :incidents do
    collection do
      get :incomplete
      get :unreviewed
    end
  end
  resources :staff_reviews, only: %i[create destroy update]

  devise_for :users
  as :user do
    get 'users/edit', to: 'devise/registrations#edit',
                      as: :edit_user_registration
    put 'users', to: 'devise/registrations#update',
                 as: :user_registration
  end
  scope :staff do
    resources :users, except: :show do
      member do
        post :deactivate
        get  :incidents
      end
    end
  end
end
