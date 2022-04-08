class Users::RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    super do |user|
      user.plans << Plan.find(session[:plan_id]) if session[:plan_id]
      session[:plan_id] = nil
    end
  end

  protected

  def after_sign_up_path_for(user)
    stored_location_for(user) || plans_path
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
