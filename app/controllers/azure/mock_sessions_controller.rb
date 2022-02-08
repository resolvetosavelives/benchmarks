# frozen_string_literal: true

# Not inheriting from ApplicationController because this is meant to live outside the app
class Azure::MockSessionsController < ActionController::Base
  COOKIE = "mock_azure_access_token"

  before_action :ensure_mock_enabled

  layout "devise" # I couldn't help but make this look a little nicer.

  def new
    redirect_to(root_path) if cookies[COOKIE]
    @post_login_redirect_uri = params[:post_login_redirect_uri]
  end

  def create
    cookies[COOKIE] = generate_cookie(params[:email])
    redirect_to params[:post_login_redirect_uri] || root_path
  end

  def destroy
    cookies.delete(COOKIE)
    sign_out :user
    redirect_to params[:post_logout_redirect_uri] || root_path
  end

  private

  # This controller shouldn't be routed to when not enabled, but better to be safe.
  def ensure_mock_enabled
    if Rails.env.production? || !Rails.application.config.azure_auth_mocked
      redirect_to "/"
    end
  end

  def generate_cookie(email)
    expires = 1.hour.from_now
    email = "#{expires.to_i}@example.com" if email.blank?

    claims = {
      exp: expires.to_i,
      sub: Base64.urlsafe_encode64(email).strip,
      email: email
    }

    token = JWT.encode(claims, nil, "none")

    { value: token, expires: expires }
  end
end
