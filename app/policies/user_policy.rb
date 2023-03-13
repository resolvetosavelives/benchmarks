# frozen_string_literal: true

class UserPolicy < AdminPolicy
  def new?
    false
  end

  def create?
    false
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def act_on?
    user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
