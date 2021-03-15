Rails.application.routes.draw do
  root to: "pages#home"
  get "plan/goals/:country_name/:assessment_type(/:plan_term)",
      to: "plans#goals", as: "plan_goals"
  get "/get-started", to: "start#index"
  resources :start, path: "get-started", only: %i[index create show update]
  resources :plans, only: %i[show index create update destroy]
  resources :worksheets, only: %i[show]
  resources :costsheets, only: %i[show]
  devise_for :users,
             controllers: {
               sessions: "users/sessions", registrations: "users/registrations"
             }

  ##
  # static pages
  get "/privacy_policy", to: "pages#privacy_policy"
  get "/reference-library",
      to: "pages#reference_library", as: "reference_library" # Benchmark Document section
  get "/document/introduction", to: "pages#introduction", as: "introduction"
  get "/document/1-national-legislation-policy-and-financing",
      to: "pages#technical_area_1", as: "technical_area_1"
  get "/document/2-ihr-coordination-communication-and-advocacy-and-reporting",
      to: "pages#technical_area_2", as: "technical_area_2"
  get "/document/3-antimicrobial-resistance",
      to: "pages#technical_area_3", as: "technical_area_3"
  get "/document/4-zoonotic-disease",
      to: "pages#technical_area_4", as: "technical_area_4"
  get "/document/5-food-safety",
      to: "pages#technical_area_5", as: "technical_area_5"
  get "/document/6-immunization",
      to: "pages#technical_area_6", as: "technical_area_6"
  get "/document/7-national-laboratory-system",
      to: "pages#technical_area_7", as: "technical_area_7"
  get "/document/8-biosafety-and-biosecurity",
      to: "pages#technical_area_8", as: "technical_area_8"
  get "/document/9-surveillance",
      to: "pages#technical_area_9", as: "technical_area_9"
  get "/document/10-human-resources",
      to: "pages#technical_area_10", as: "technical_area_10"
  get "/document/11-emergency-preparedness",
      to: "pages#technical_area_11", as: "technical_area_11"
  get "/document/12-emergency-response-operations",
      to: "pages#technical_area_12", as: "technical_area_12"
  get "/document/13-linking-public-health-and-security-authorities",
      to: "pages#technical_area_13", as: "technical_area_13"
  get "/document/14-medical-countermeasures-and-personnel-deployment",
      to: "pages#technical_area_14", as: "technical_area_14"
  get "/document/15-risk-communication",
      to: "pages#technical_area_15", as: "technical_area_15"
  get "/document/16-points-of-entry",
      to: "pages#technical_area_16", as: "technical_area_16"
  get "/document/17-chemical-events",
      to: "pages#technical_area_17", as: "technical_area_17"
  get "/document/18-radiation-emergencies",
      to: "pages#technical_area_18", as: "technical_area_18"
  get "/document/acronyms", to: "pages#acronyms", as: "acronyms"
  get "/document/glossary", to: "pages#glossary", as: "glossary"
  get "/document/acknowledgement",
      to: "pages#acknowledgement", as: "acknowledgement"
end
