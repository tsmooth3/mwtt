class TreeEntry < ApplicationRecord
  belongs_to :user
  belongs_to :family
  belongs_to :season

  validates :entry_date, presence: true
  validates :tree_count, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :for_season, ->(season) { where(season: season) }
  scope :for_family, ->(family) { where(family: family) }
  scope :recent, -> { order(entry_date: :desc) }
end
