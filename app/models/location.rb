class Location < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :tree_entries, dependent: :nullify

  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  scope :visible, -> { where(hidden: false) }

  NEARBY_DEGREES = 0.01

  def self.nearby(latitude, longitude, radius_degrees: NEARBY_DEGREES)
    visible.where(
      latitude: (latitude - radius_degrees)..(latitude + radius_degrees),
      longitude: (longitude - radius_degrees)..(longitude + radius_degrees)
    )
  end

  def hide!
    update!(hidden: true)
  end

  def unhide!
    update!(hidden: false)
  end

  def shared?
    tree_entries.where.not(user_id: creator_id).exists?
  end

  def movable_by?(user)
    return false unless owned_or_admin?(user)
    !shared?
  end

  alias_method :deletable_by?, :movable_by?

  def hideable_by?(user)
    owned_or_admin?(user)
  end

  def owned_or_admin?(user)
    return false unless user

    creator_id == user.id || user.any_family_admin?
  end

  def season_entries(season)
    tree_entries.for_season(season).recent.includes(:user, :family)
  end

  def latest_seen_entry(season)
    season_entries(season).where.not(seen: nil).first
  end

  def remaining_for(season)
    last_entry_for(season)&.remaining
  end

  def collected_for(season)
    season_entries(season).sum(:collected)
  end

  def last_entry_for(season)
    season_entries(season).first
  end

  def operational_state(season)
    leftover = remaining_for(season)
    collected = collected_for(season)

    if leftover.nil?
      :unknown
    elsif leftover.positive?
      :inventory
    elsif collected.positive?
      :cleared
    else
      :empty
    end
  end

  def display_name
    name.presence || "Unnamed pin"
  end
end
