class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable
  has_many :plans

  # Azure docs state that email must not be used as an unique identifier.
  # Since the code still allows email login, I'm not sure if there will be
  # a conflict that will eventually be caused by Azure's given email.
  # Email may also not be sent in the token.
  def self.by_azure_sub_claim!(azure_identity, email)
    user = User.where(azure_identity: azure_identity).first_or_initialize
    user.email = email
    user.save!
    user
  end

  protected

  def password_required?
    return false if Rails.application.config.azure_auth_enabled
    super
  end

  def email_required?
    return false if Rails.application.config.azure_auth_enabled
    super
  end

  def confirmation_required?
    return false if Rails.application.config.azure_auth_enabled
    Rails.env.production?
  end
end
