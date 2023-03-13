# frozen_string_literal: true

class Avo::AdminController < Avo::ResourcesController
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def user_not_authorized
    flash[:alert] = "You are not authorized to do that."
    redirect_to main_app.plans_url
  end
end
