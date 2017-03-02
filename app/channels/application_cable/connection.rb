module ApplicationCable
  class Connection < ActionCable::Connection::Base
    attr_reader :jwt

    identified_by :current_user

    def connect
      @jwt = token_decoder.call(request.params[:jwt]) or reject_unauthorized_connection
      self.current_user = find_verified_user
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      reject_unauthorized_connection
    end

    private

    def find_verified_user
      User.find(jwt['sub'])
    end

    def token_decoder
      @decoder ||= Warden::JWTAuth::TokenDecoder.new
    end
  end
end
