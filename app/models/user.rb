class User < ApplicationRecord
  # not sure why they didn't just add JWT to the inflections list...
  Devise::Models::JWTAuthenticatable = Devise::Models::JwtAuthenticatable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JWTBlacklist

  has_one_attached :avatar

  has_many :uploads, dependent: :restrict_with_exception
  has_many :permissions, dependent: :delete_all
  has_many :aircraft, through: :permissions, source: :aircraft

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def jwt_payload
    {email: email}
  end
end
