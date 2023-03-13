# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
