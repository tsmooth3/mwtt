class ReassignEntriesToWinterSeasons < ActiveRecord::Migration[8.0]
  def up
    Season.reassign_entries!
  end

  def down
    # Calendar-year assignment is gone on purpose.
  end
end
