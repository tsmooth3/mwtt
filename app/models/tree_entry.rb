class TreeEntry < ApplicationRecord
  attr_accessor :latitude, :longitude, :location_name

  belongs_to :user
  belongs_to :family, optional: true
  belongs_to :season
  belongs_to :location, optional: true, autosave: true

  before_validation :normalize_collected
  before_validation :assign_season_from_date

  validates :entry_date, presence: true
  validates :collected, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :seen, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :must_report_something
  validate :family_required_when_collecting
  validate :location_required_when_seen
  validate :seen_not_less_than_collected
  validate :empty_seen_has_no_collection

  scope :for_season, ->(season) { where(season: season) }
  scope :for_family, ->(family) { where(family: family) }
  scope :recent, -> { order(entry_date: :desc, created_at: :desc) }
  scope :collections, -> { where("collected > 0") }
  scope :scouting, -> { where("collected = 0 OR (seen IS NOT NULL AND seen > collected)") }

  def remaining
    return if seen.nil?

    seen - collected
  end

  def collection?
    collected.positive?
  end

  def empty_check?
    seen == 0 && collected == 0
  end

  def sighting?
    seen.present? && !collection? && !empty_check?
  end

  def leftover?
    remaining.to_i.positive?
  end

  private

  def normalize_collected
    self.collected = 0 if collected.nil?
  end

  def assign_season_from_date
    return if entry_date.blank?

    self.season = Season.for_date(entry_date)
  end

  def must_report_something
    return if collected.positive?
    return if seen.present?

    errors.add(:base, "must report trees seen or collected")
  end

  def family_required_when_collecting
    return unless collected.to_i.positive?
    return if family.present?

    errors.add(:family, "must be selected")
  end

  def location_required_when_seen
    return if seen.nil?
    return if location.present?

    errors.add(:location, "must be pinned when reporting trees seen")
  end

  def seen_not_less_than_collected
    return if seen.nil?
    return if seen >= collected.to_i

    errors.add(:seen, "cannot be less than trees collected")
  end

  def empty_seen_has_no_collection
    return unless seen == 0
    return unless collected.to_i.positive?

    errors.add(:seen, "cannot be zero when trees were collected")
  end
end
