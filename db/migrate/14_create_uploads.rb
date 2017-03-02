class CreateUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :uploads do |t|
      t.belongs_to :user, null: false, foreign_key: {on_delete: :restrict}
      t.belongs_to :aircraft, null: false, foreign_key: {on_delete: :cascade}

      t.integer :state, limit: 1, null: false, default: 0
      t.string :error
      t.string :workflow_uuid, limit: 36

      t.timestamp :earliest_time, :latest_time

      t.timestamps
    end
  end
end
