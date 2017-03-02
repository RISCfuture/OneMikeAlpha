class JWTBlacklist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist
end
