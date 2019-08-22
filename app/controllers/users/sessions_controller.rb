class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    super do |user|
      user.plans << Plan.find(session[:plan_id]) if session[:plan_id]
      session[:plan_id] = nil
    end
  end
end
