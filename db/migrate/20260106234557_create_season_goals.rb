class CreateSeasonGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :season_goals do |t|
      t.references :family, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.integer :goal_count, null: false

      t.timestamps
    end

    add_index :season_goals, [:family_id, :season_id], unique: true
  end
end
