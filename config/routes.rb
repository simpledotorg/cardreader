Rails.application.routes.draw do
  root "districts#index"

  resources :districts do
    resources :facilities do
      resources :patients
    end
  end
end
