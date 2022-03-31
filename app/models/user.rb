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

  def azure_authenticated?
    Rails.application.config.azure_auth_enabled && azure_identity.present?
  end

  protected

  # TODO: Solve requiring password when email login is used.
  def password_required?
    !azure_authenticated? && super
  end

  def email_required?
    !azure_authenticated? && super
  end

  def confirmation_required?
    !azure_authenticated? && Rails.env.production?
  end
end
