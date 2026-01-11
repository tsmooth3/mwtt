class Family < ApplicationRecord
  has_many :family_memberships, dependent: :destroy
  has_many :users, through: :family_memberships
  has_many :tree_entries, dependent: :destroy

  validates :name, presence: true

  def admins
    users.joins(:family_memberships)
         .where(family_memberships: { is_admin: true })
  end
end
