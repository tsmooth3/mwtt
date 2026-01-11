class SeasonGoal < ApplicationRecord
  belongs_to :season

  validates :goal_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :season_id, uniqueness: true
end
