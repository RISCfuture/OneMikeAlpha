class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions, primary_key: %i[user_id aircraft_id] do |t|
      t.belongs_to :user, foreign_key: {on_delete: :cascade}
      t.belongs_to :aircraft, foreign_key: {on_delete: :cascade}

      t.integer :level, limit: 1, null: false, default: 0

      t.timestamps
    end
  end
end
