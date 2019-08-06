Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#show'
  get '/assessments(/:country)(/:assessment)', to: 'assessment#show'
  resources :plan, only: [:show]
end
