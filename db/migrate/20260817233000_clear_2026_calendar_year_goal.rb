class Clear2026CalendarYearGoal < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      DELETE FROM season_goals
      WHERE goal_count = 250
        AND season_id IN (SELECT id FROM seasons WHERE year = 2026)
    SQL
  end

  def down
    # 250 on season 2026 was the old calendar-year USA age.
  end
end
