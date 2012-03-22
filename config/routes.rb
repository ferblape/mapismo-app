MapismoApp::Application.routes.draw do
  root to: "site#home"

  get   '/login',                   to: 'sessions#new', as: :login
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure',            to: 'sessions#failure'
  get   '/logout',                  to: 'sessions#destroy', as: :logout

  get       '/map/:user_id/:id',    to: 'maps#show', as: :map
  post      '/map/preview',         to: 'maps#preview', as: :map_preview
  resources :maps,                  except: [:edit, :update, :show]
end
