class RemoveFamilyFromSeasonGoals < ActiveRecord::Migration[8.0]
  def change
    remove_index :season_goals, [:family_id, :season_id] if index_exists?(:season_goals, [:family_id, :season_id])
    remove_reference :season_goals, :family, null: false, foreign_key: true
    
    # Remove existing season_id index if it exists (created by t.references)
    remove_index :season_goals, :season_id if index_exists?(:season_goals, :season_id)
    # Add unique index on season_id
    add_index :season_goals, :season_id, unique: true
  end
end
