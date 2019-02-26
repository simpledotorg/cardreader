Rails.application.routes.draw do
  devise_scope :user do
    authenticated :user do
      root "districts#index", as: :user_root
    end

    unauthenticated :user do
      root to: "devise/sessions#new"
    end
  end

  devise_for :users
  resources :users

  resources :districts do
    resources :facilities, except: [:new, :create] do
      post :sync
      resources :patients do
        post :sync
        resources :visits
      end
    end
  end
end