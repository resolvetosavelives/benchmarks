Rails.application.routes.draw do
  root to: "pages#home"
  match "/get_started", to: "plans#get_started", via: [:get, :post]
  get "plan/goals/:country_name/:assessment_type(/:plan_term)(/:areas)", to: "plans#goals", as: "plan_goals"
  resources :plans, only: %i[show index create update destroy]
  resources :worksheets, only: %i[show]
  resources :costsheets, only: %i[show]
  devise_for :users, controllers: {sessions: "users/sessions", registrations: "users/registrations"}

  ##
  # static pages
  get "/privacy_policy", to: "pages#privacy_policy"
  ##
  # Benchmark Document section
  get "/document/introduction", to: "pages#introduction", as: "introduction"
  get "/document/1-national-legislation-policy-and-financing", to: "pages#technical_area_1", as: "technical_area_1"
  get "/document/2-ihr-coordination-communication-and-advocacy-and-reporting", to: "pages#technical_area_2", as: "technical_area_2"
  get "/document/3-antimicrobial-resistance", to: "pages#technical_area_3", as: "technical_area_3"
  get "/document/acronyms", to: "pages#acronyms", as: "acronyms"
  get "/document/acknowledgement", to: "pages#acknowledgement", as: "acknowledgement"
end
