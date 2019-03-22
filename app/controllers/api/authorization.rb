# frozen_string_literal: true

module Api
  module Authorization
    def require_authorization
      unless referrer_is_gk? || valid_authenticity_token?(session, request.headers['X-CSRF-Token'])
        render json: { errors: ['Not authorized'] }, status: 403 
      end
    end

    def referrer_is_gk?
      /\.greatschools\.org\/gk/.match?(request.referrer)
    end

    def referrer_allowed?
      /\.greatschools\.org/.match?(request.referrer)
    end
  end
end