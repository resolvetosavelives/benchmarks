class User < ApplicationRecord
  include UserSeed
  ROLES = %w[user admin].freeze
  STATUSES = %w[active inactive].freeze
  AFFILIATIONS = [
    "Government",
    "Private sector",
    "Academia",
    "Civil society",
    "International organization including donors",
    "Other"
  ].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable

  # NB: the association is: users.country_alpha3 => countries.alpha3
  belongs_to :country,
             foreign_key: "country_alpha3",
             primary_key: "alpha3",
             required: false,
             inverse_of: :users
  has_many :plans

  validates :email, uniqueness: true
  validates :azure_identity, uniqueness: { allow_nil: true }
  validates :role, inclusion: ROLES
  validates :status, inclusion: STATUSES

  after_initialize :set_defaults

  def set_defaults
    self.role ||= ROLES.first
    self.status ||= STATUSES.first
  end

  def azure_authenticated?
    Rails.application.config.azure_auth_enabled && azure_identity.present?
  end

  def admin?
    role.to_s.downcase.eql?("admin")
  end

  def admin!
    update!(role: "admin")
  end

  def remove_admin!
    update!(role: "user")
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
