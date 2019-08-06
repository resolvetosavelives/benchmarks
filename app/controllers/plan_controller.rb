class PlanController < ApplicationController
  def show
    @plan = Plan.find_by_id!(params.fetch(:id))
  end
end
