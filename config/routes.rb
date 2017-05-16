Rails.application.routes.draw do
  root 'incidents#index'
  resources :incidents do
    collection do
      get :incomplete
    end
  end

  devise_for :users
  as :user do
    get 'users/edit', to: 'devise/registrations#edit', as: :edit_user_registration
    put 'users', to: 'devise/registrations#update', as: :user_registration           
  end
  scope :staff do
    resources :users, except: :show do
      member do
        get :incidents
      end
    end
  end
end
