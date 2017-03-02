class Permission < ApplicationRecord
  belongs_to :user
  belongs_to :aircraft

  self.primary_key = %i[user_id aircraft_id]

  enum level: %i[view upload admin]
end
