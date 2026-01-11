class CreateTreeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :tree_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :family, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.date :entry_date, null: false
      t.integer :tree_count, null: false

      t.timestamps
    end

    add_index :tree_entries, [ :family_id, :season_id ]
    add_index :tree_entries, :entry_date
  end
end
