# frozen_string_literal: true

module Api
  module Authorization
    def require_authorization
      unless referrer_allowed? && valid_authenticity_token?(session, request.headers['X-CSRF-Token'])
        render json: { errors: ['Not authorized'] }, status: 403 
      end
    end

    def referrer_allowed?
      /\.greatschools\.org/.match?(request.referrer)
    end
  end
end