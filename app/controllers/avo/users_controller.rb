# frozen_string_literal: true

class Avo::UsersController < Avo::AdminController
  def after_update_path
    resources_users_path
  end
end
