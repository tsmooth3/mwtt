class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :family_memberships, dependent: :destroy
  has_many :families, through: :family_memberships
  has_many :tree_entries, dependent: :destroy

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def current_family
    families.first
  end

  def family_admin?(family)
    family_memberships.find_by(family: family)&.is_admin || false
  end

  def any_family_admin?
    family_memberships.where(is_admin: true).any?
  end
end
