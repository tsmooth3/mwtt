class FamilyMembership < ApplicationRecord
  belongs_to :user
  belongs_to :family

  validates :user_id, uniqueness: { scope: :family_id }
  validate :user_can_only_have_one_family

  private

  def user_can_only_have_one_family
    if user && user.family_memberships.where.not(id: id).exists?
      errors.add(:user, "can only be a member of one family")
    end
  end
end
