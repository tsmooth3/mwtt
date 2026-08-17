class Season < ApplicationRecord
  WINDOW_START_MONTH = 12
  WINDOW_START_DAY = 1
  WINDOW_END_MONTH = 2
  WINDOW_END_DAY = 15

  USA_FOUNDING_YEAR = 1776

  has_many :tree_entries, dependent: :destroy
  has_one :season_goal, dependent: :destroy

  validates :year, presence: true, uniqueness: true

  def self.find_or_create_by_year(year)
    find_or_create_by(year: year)
  end

  def self.in_window?(date)
    date = date.to_date
    if date.month == WINDOW_START_MONTH && date.day >= WINDOW_START_DAY
      true
    elsif date.month < WINDOW_END_MONTH || (date.month == WINDOW_END_MONTH && date.day <= WINDOW_END_DAY)
      true
    else
      false
    end
  end

  def self.year_for(date)
    date = date.to_date
    if date.month == WINDOW_START_MONTH && date.day >= WINDOW_START_DAY
      date.year
    elsif date.month < WINDOW_END_MONTH || (date.month == WINDOW_END_MONTH && date.day <= WINDOW_END_DAY)
      date.year - 1
    else
      date.year
    end
  end

  def self.for_date(date)
    find_or_create_by_year(year_for(date))
  end

  def self.current(on: Date.current)
    find_or_create_by_year(year_for(on))
  end

  def previous
    self.class.find_or_create_by_year(year - 1)
  end

  def live?(on: Date.current)
    year >= self.class.year_for(on)
  end

  def recap?(on: Date.current)
    !live?(on: on)
  end

  def default_goal_count
    year + 1 - USA_FOUNDING_YEAR
  end

  def goal_count
    season_goal&.goal_count || default_goal_count
  end

  def self.reassign_entries!
    TreeEntry.find_each do |entry|
      season = for_date(entry.entry_date)
      entry.update_columns(season_id: season.id) if entry.season_id != season.id
    end
  end
end
