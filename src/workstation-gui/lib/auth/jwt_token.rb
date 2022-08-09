module Auth
  class JwtToken
    SECRET_KEY = Rails.application.credentials.secret_key_base.to_s

    class << self
      def encode(payload, exp = 30.seconds.from_now) #1.week.from_now)
        payload[:exp] = exp.to_i

        JWT.encode(payload, SECRET_KEY)
      end

      def decode(token)
        decoded = JWT.decode(token, SECRET_KEY)[0]

        decoded.to_h.with_indifferent_access
      end
    end
  end
end