# frozen_string_literal: true

class HealthchecksController < ApplicationController
  def index
    ActiveRecord::Base.connection.execute("select 1")
    ActiveRecord::Migration.check_pending!
    render json: {
             RAILS_ENV: Rails.env.to_s,
             COMMIT_SHA: Rails.application.config.commit_sha,
             DOCKER_IMAGE_TAG: Rails.application.config.docker_image_tag,
             APPLICATION_HOST: Rails.application.config.application_host,
             WEBSITE_AUTH_ENABLED: Rails.application.config.azure_auth_enabled,
             headers: request.env.select { |k, v| k =~ /^HTTP_/ }
           }
  end
end
