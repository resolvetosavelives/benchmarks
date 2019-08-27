require 'rubyXL/convenience_methods'

class CostsheetsController < ApplicationController
  def show
    plan = Plan.find_by_id! params.fetch(:id)

    send_data (CostSheet.new plan).to_s,
              filename: "#{plan.name} costing tool.xlsx",
              type: 'application/vnd.ms-excel'
  end
end
