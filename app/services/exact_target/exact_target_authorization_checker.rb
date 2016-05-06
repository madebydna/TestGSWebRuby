class ExactTarget
  class ExactTargetAuthorizationChecker

    NOT_AUTHORIZED_MESSAGE = "Not Authorized"
    NOT_AUTHORIZED_ERROR_CODE = 0
    INVALID_CREDENTIALS_MESSAGE = "Unauthorized"
    INVALID_CREDENTIALS_CODE = 1

    attr_reader :result

    def initialize(result)
      @result = result
    end

    def self.authorize(result)
      new(result).authorize
    end

    def self.authorize_token(result)
      new(result).authorize
    end

    def authorize
      if invalid_authorization_token_error?
        raise GsExactTargetAuthorizationError, 'invalid or expired auth token'
      elsif invalid_credentials_error?
        raise GsExactTargetAuthorizationError, 'invalid credentials'
      end
      result
    end

    def authorize_token
      raise GsExactTargetAuthorizationError, 'invalid token response' if invalid_authorization_token?
      authorize
    end

    def invalid_authorization_token_error?
      (result["errorcode"] == NOT_AUTHORIZED_ERROR_CODE  && result["message"] == NOT_AUTHORIZED_MESSAGE)
    end

    def invalid_authorization_token?
      ! ( result.has_key?("accessToken") && result.has_key?("expiresIn") )
    end

    def invalid_credentials_error?
      result["errorcode"] == INVALID_CREDENTIALS_CODE && result["message"] == INVALID_CREDENTIALS_MESSAGE
    end

  end
end

