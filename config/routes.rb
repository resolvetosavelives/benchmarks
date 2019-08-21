Rails.application.routes.draw do
  devise_for :users, controllers: { sesssions: 'users/sessions' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#show'
  post '/country_select', to: 'country_select#create'
  get '/goals(/:country)(/:assessment_type)', to: 'goals#show'
  post '/goals', to: 'goals#create'
  resources :plans, only: %i[show index update]
  resources :worksheets, only: %i[show]
end
