Rails.application.routes.draw do
  root to: "pages#home"
  get "/privacy_policy", to: "pages#privacy_policy"
  match "/get_started", to: "plans#get_started", via: [:get, :post]
  get "plan/goals/:country_name/:assessment_type(/:plan_term)(/:areas)", to: "plans#goals", as: "plan_goals"
  resources :plans, only: %i[show index create update destroy]
  resources :worksheets, only: %i[show]
  resources :costsheets, only: %i[show]
  devise_for :users, controllers: {sessions: "users/sessions", registrations: "users/registrations"}
end
