Rails.application.routes.draw do
  root "districts#index"

  resources :districts do
    resources :facilities do
      resources :patients do
        resources :visits
      end
    end
  end
end
