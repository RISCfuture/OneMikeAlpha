class CreateJWTBlacklists < ActiveRecord::Migration[5.2]
  def change
    create_table :jwt_blacklists, id: false, primary_key: :jti do |t|
      t.string :jti, null: false, unique: true
    end
  end
end
