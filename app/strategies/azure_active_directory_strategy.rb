# frozen_string_literal: true
class AzureActiveDirectoryStrategy < Devise::Strategies::Base
  # Real token names are:
  #  X-MS-TOKEN-AAD-ACCESS-TOKEN
  #  X-MS-TOKEN-AAD-ID-TOKEN
  #
  # TODO: Both of these verify the same way and contain the same sub claim.
  #       Is one better than the other?
  ID_TOKEN_HEADER = "HTTP_X_MS_TOKEN_AAD_ID_TOKEN"
  ACCESS_TOKEN_HEADER = "HTTP_X_MS_TOKEN_AAD_ACCESS_TOKEN"

  def valid?
    puts "env.inspect: "
    puts env.inspect
    Rails.logger.info "env: #{env.inspect}"
    Rails.logger.info "AzureActiveDirectoryStrategy: valid? #{token.inspect}"
    Rails.application.config.azure_auth_enabled && token.present?
  end

  def authenticate!
    # Azure's docs suggest not verifying the token if it's passed directly to the app like this.
    # https://docs.microsoft.com/en-us/azure/active-directory/develop/access-tokens#validating-tokens
    # For now we're not verifying because azure sends this to the app directly and it's not from a user.
    Rails.logger.info("AzureActiveDirectoryStrategy: authenticate!")
    claims, _ = JWT.decode(token, nil, false)
    Rails.logger.info(
      "AzureActiveDirectoryStrategy: authenticate! claims: #{claims.inspect}"
    )

    if claims["sub"].present?
      # the email may not be present.
      user = User.by_azure_sub_claim!(claims["sub"], claims["email"])
      Rails.logger.info(
        "AzureActiveDirectoryStrategy: authenticate! user: #{user.inspect}"
      )
      success!(user)
    else
      Rails.logger.info("AzureActiveDirectoryStrategy: failed sub")
      fail!("Authentication failed")
    end
  rescue JWT::DecodeError, ActiveRecord::ActiveRecordError => e
    Rails.logger.info("AzureActiveDirectoryStrategy: failed error #{e.inspect}")
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
    env[ID_TOKEN_HEADER] || env[ACCESS_TOKEN_HEADER]
  end
end
