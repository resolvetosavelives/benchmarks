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

  def password_required?
    !azure_authenticated? && super
  end

  def email_required?
    !azure_authenticated? && super
  end

  def confirmation_required?
    !azure_authenticated? && Rails.application.config.confirmation_required
  end
end
