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
