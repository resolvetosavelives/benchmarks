require 'rubyXL/convenience_methods'

# This controller generates the printable worksheet. There is nothing
# particularly interesting about it.
class WorksheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_ownership

  def show
    plan = Plan.find_by_id! params.fetch(:id)

    send_data (Worksheet.new plan).to_s,
              filename: "#{plan.name} worksheet.xlsx",
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
