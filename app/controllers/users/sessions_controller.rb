class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    super do |user|
      user.plans << Plan.find(session[:plan_id]) if session[:plan_id]
      session[:plan_id] = nil
    end
  end

  protected

  def after_sign_in_path_for(user)
    stored_location_for(user) || plans_path
  end

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) do
        if azure_authenticated?
          redirect_to azure_logout_path(
                        post_logout_redirect_uri:
                          after_sign_out_path_for(resource_name)
                      )
        else
          redirect_to after_sign_out_path_for(resource_name)
        end
      end
    end
  end
end
