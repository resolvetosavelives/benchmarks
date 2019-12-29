class CostsheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_ownership

  def show
    plan = Plan.find_by_id! params.fetch(:id)
    send_data CostSheet.new(plan).to_s,
      filename: "#{plan.name} costing tool.xlsx",
      type: 'application/vnd.ms-excel'
  end

  def check_ownership
    plan_id = params.fetch(:id).to_i
    if current_user.plan_ids.exclude?(plan_id)
      flash[:alert] = 'You are not allowed to access this plan'
      redirect_to plans_path
    end
  end
end
