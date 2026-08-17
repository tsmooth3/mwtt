class RemoveTreeCountFromTreeEntries < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        execute "UPDATE tree_entries SET collected = tree_count WHERE collected IS NULL OR collected = 0 AND tree_count IS NOT NULL"
        remove_column :tree_entries, :tree_count
      end
      dir.down do
        add_column :tree_entries, :tree_count, :integer
        execute "UPDATE tree_entries SET tree_count = collected"
        change_column_null :tree_entries, :tree_count, false
      end
    end
  end
end
