Rails.application.routes.draw do
  # Mock Azure Active Directory Authentication
  #
  # These routes serve two purposes.
  # 1. The named routes provide easy usage for real production views where we
  #    need to login with Azure. These are the Azure auth routes.
  # 2. When the mock is enabled, we resolve the routes to a mock controller.
  #    When the middleware MockAzureAuthMiddleware is inserted to intercept the
  #    cookie, the Azure::MockSessions controller behaves like real Azure Auth.
  #
  # These routes will never make it to the controller in production.
  # Azure will intercept the routes before they ever get to the app.
  # The constraints help prevent access when running elsewhere, e.g. Heroku.
  constraints(-> { Rails.application.config.azure_auth_mocked }) do
    scope path: ".auth", as: "azure", module: "azure" do
      get "login/aad", to: "mock_sessions#new", as: :login
      post "login/aad", to: "mock_sessions#create"
      get "logout", to: "mock_sessions#destroy", as: :logout
    end
  end

  devise_for :users, controllers: {
    sessions: "users/sessions", registrations: "users/registrations"
  }

  get "/get-started", to: "start#index"
  resources :start, path: "get-started", only: %i[index create show update]
  resources :plans, only: %i[show index create update destroy]
  resources :worksheets, only: %i[show]
  resources :costsheets, only: %i[show]
  get "plan/goals/:country_name/:assessment_type(/:plan_term)",
      to: "plans#goals", as: "plan_goals"

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

  get "/healthcheck", to: "healthchecks#index", as: "healthcheck"

  root to: "pages#home"
end
