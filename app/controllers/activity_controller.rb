class ActivityController < ApplicationController
  def create
    @benchmark_id = params.fetch(:benchmark_id)
    @new_activity = params.fetch(:new_activity)
  end
end
