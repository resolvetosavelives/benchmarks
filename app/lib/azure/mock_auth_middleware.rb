# If the cookie set by Azure::MockSessionsController is present,
# add the token it contains as a request header, just like Azure does.
module Azure
  class MockAuthMiddleware
    def initialize(app)
      if Rails.env.production?
        raise "Don't load Azure::MockAuthMiddleware in production"
      end
      @app = app
    end

    def call(env)
      if Rails.application.config.azure_auth_mocked
        request = Rack::Request.new(env)
        token = request.cookies[Azure::MockSessionsController::COOKIE]
        env[Azure::AuthStrategy::ID_TOKEN_HEADER_ENV] = token if token
      end

      @app.call(env)
    end
  end
end
