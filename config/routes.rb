Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#show'
  get '/privacy_policy', to: 'privacy_policy#show'
  post '/country_select', to: 'country_select#create'
  get '/goals(/:country)(/:assessment_type)', to: 'goals#show'
  post '/goals', to: 'goals#create'
  resources :plans, only: %i[show index create update destroy]
  resources :worksheets, only: %i[show]
  resources :costsheets, only: %i[show]
end
