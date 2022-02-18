# frozen_string_literal: true

class HealthchecksController < ApplicationController
  def index
    ActiveRecord::Base.connection.execute("select 1")
    ActiveRecord::Migration.check_pending!
    render json: {
             RAILS_ENV: Rails.env.to_s,
             COMMIT_SHA: Rails.application.config.commit_sha,
             DOCKER_IMAGE_TAG: Rails.application.config.docker_image_tag,
             WEBSITE_HOSTNAME: Rails.application.config.website_hostname,
             WEBSITE_AUTH_ENABLED: Rails.application.config.azure_auth_enabled
           }
  end
end
