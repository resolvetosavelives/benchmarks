# frozen_string_literal: true
class AzureActiveDirectoryStrategy < Devise::Strategies::Base
  # Real token names are:
  #  X-MS-TOKEN-AAD-ACCESS-TOKEN
  #  X-MS-TOKEN-AAD-ID-TOKEN
  #
  # TODO: Both of these verify the same way and contain the same sub claim.
  #       Is one better than the other?
  TOKEN_HEADER = "HTTP_X_MS_TOKEN_AAD_ACCESS_TOKEN"

  def valid?
    Rails.application.config.azure_auth_enabled && token.present?
  end

  def authenticate!
    # Some of Azure's docs suggest not verifying the token if it's passed directly to the app like this.
    # For now we're not verifying
    claims, _header = JWT.decode(token, nil, false)

    fail!("Authentication failed") if claims["sub"].blank?

    user = User.by_azure_identity!(claims["sub"], claims["email"])

    success!(user)
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

  def token
    env[TOKEN_HEADER]
  end
end
