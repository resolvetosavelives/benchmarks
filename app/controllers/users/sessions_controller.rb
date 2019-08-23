class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    super do |user|
      user.plans << Plan.find(session[:plan_id]) if session[:plan_id]
      session[:plan_id] = nil
    end
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || plans_path
  end
end
