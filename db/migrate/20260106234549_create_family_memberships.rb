class CreateFamilyMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :family_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :family, null: false, foreign_key: true
      t.boolean :is_admin, default: false, null: false

      t.timestamps
    end

    add_index :family_memberships, [ :user_id, :family_id ], unique: true
  end
end
