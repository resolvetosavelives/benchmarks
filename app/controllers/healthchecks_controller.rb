# frozen_string_literal: true

class HealthchecksController < ApplicationController
  def index
    ActiveRecord::Base.connection.execute("select 1")
    ActiveRecord::Migration.check_pending!
    head :no_content
  end
end
