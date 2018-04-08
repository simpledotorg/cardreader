Rails.application.routes.draw do
  resources :facilities do
    resources :patients
  end
end
