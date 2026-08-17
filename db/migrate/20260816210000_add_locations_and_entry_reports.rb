class AddLocationsAndEntryReports < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :name
      t.boolean :hidden, default: false, null: false
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :locations, [ :latitude, :longitude ]

    change_table :tree_entries do |t|
      t.references :location, foreign_key: true
      t.integer :seen
      t.integer :collected
    end

    reversible do |dir|
      dir.up do
        execute "UPDATE tree_entries SET collected = tree_count"
        change_column_null :tree_entries, :collected, false
        change_column_default :tree_entries, :collected, 0
        change_column_null :tree_entries, :family_id, true
      end
      dir.down do
        change_column_null :tree_entries, :family_id, false
        change_column_null :tree_entries, :collected, true
        change_column_default :tree_entries, :collected, nil
      end
    end
  end
end
