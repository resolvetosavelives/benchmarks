class Users::RegistrationsController < Devise::RegistrationsController
  before_action :disable_when_azure_auth_enabled

  # POST /resource
  def create
    super do |user|
      user.plans << Plan.find(session[:plan_id]) if session[:plan_id]
      session[:plan_id] = nil
    end
  end

  protected

  def disable_when_azure_auth_enabled
    redirect_to root_path if Rails.application.config.azure_auth_enabled
  end

  def after_sign_up_path_for(user)
    stored_location_for(user) || plans_path
  end
end
