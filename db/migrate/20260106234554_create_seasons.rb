class CreateSeasons < ActiveRecord::Migration[8.0]
  def change
    create_table :seasons do |t|
      t.integer :year, null: false

      t.timestamps
    end

    add_index :seasons, :year, unique: true
  end
end
