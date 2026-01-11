class Season < ApplicationRecord
  has_many :tree_entries, dependent: :destroy
  has_many :season_goals, dependent: :destroy

  validates :year, presence: true, uniqueness: true

  def self.find_or_create_by_year(year)
    find_or_create_by(year: year)
  end
end
