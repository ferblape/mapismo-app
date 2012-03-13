MapismoApp::Application.routes.draw do
  root to: "site#home"

  get   '/login',                   to: 'sessions#new', as: :login
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure',            to: 'sessions#failure'
  get   '/logout',                  to: 'sessions#destroy', as: :logout
  
  resources :maps, except: [:update]
end
