# frozen_string_literal: true
class AzureActiveDirectoryStrategy < Devise::Strategies::Base
  # Real token names are:
  #  X-MS-TOKEN-AAD-ACCESS-TOKEN
  #  X-MS-TOKEN-AAD-ID-TOKEN
  #
  # We have it configured to send id token.
  ID_TOKEN_HEADER = "HTTP_X_MS_TOKEN_AAD_ID_TOKEN"

  def valid?
    Rails.application.config.azure_auth_enabled && token.present?
  end

  def authenticate!
    # Azure's docs suggest not verifying the token if it's passed directly to the app like this.
    # https://docs.microsoft.com/en-us/azure/active-directory/develop/access-tokens#validating-tokens
    # For now we're not verifying because azure sends this to the app directly and it's not from a user.
    claims, _ = JWT.decode(token, nil, false)

    if claims["sub"].present?
      Rails.logger.info("Claims: #{claims.inspect}")

      # the email may not be present.
      user = User.by_azure_sub_claim!(claims["sub"], claims["email"])
      success!(user)
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

  def token
    env[ID_TOKEN_HEADER]
  end
end
