# frozen_string_literal: true
module Azure
  class AuthStrategy < Devise::Strategies::Base
    # Real token names are:
    #  X-MS-TOKEN-AAD-ACCESS-TOKEN
    #  X-MS-TOKEN-AAD-ID-TOKEN
    #
    # We have it configured to send id token.
    ID_TOKEN_HEADER_HTTP = "X-MS-TOKEN-AAD-ID-TOKEN"
    ID_TOKEN_HEADER_ENV = "HTTP_X_MS_TOKEN_AAD_ID_TOKEN"

    def valid?
      Rails.application.config.azure_auth_enabled && token.present?
    end

    def authenticate!
      # We don't verify the JWT because we receive it securely in a protected header.
      # Azure's docs suggest not verifying the token in this case.
      # https://docs.microsoft.com/en-us/azure/active-directory/develop/access-tokens#validating-tokens
      claims, _ = JWT.decode(token, nil, false)
      if claims["sub"].present?
        success!(user_from_claims(claims))
      else
        fail!("Authentication failed")
      end
    rescue JWT::DecodeError, ActiveRecord::ActiveRecordError => e
      fail!("Authentication failed")
    end

    # https://stackoverflow.com/questions/43727777/rails-5-and-devise-how-i-disable-sessions-on-a-token-based-strategy-without-alt
    def store?
      false
    end

    def clean_up_csrf?
      false
    end

    private

    # Note: we're receiving the v1 token despite requesting v2.
    # I don't know why, but I tried to make it flexible in case it changes.
    def user_from_claims(claims)
      Rails.logger.debug("Claims: #{claims.inspect}")
      user = User.where(azure_identity: claims["sub"]).first_or_initialize

      # Rather than store in `email`, we use `name` so that we don't interfere
      # with email. Azure says the email is not unique and yet we expect
      # our email field to be unique. Email remains only for email/pwd login.
      user.name =
        claims["preferred_username"] || claims["email"] || claims["name"] # preferred_username might be an email too.
      user.save!
      user
    end

    def token
      env[ID_TOKEN_HEADER_ENV]
    end
  end
end
