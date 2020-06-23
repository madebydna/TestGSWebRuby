class ExactTarget
  class AuthorizationChecker

    NOT_AUTHORIZED_MESSAGE = "Not Authorized"
    NOT_AUTHORIZED_ERROR_CODE = 0
    INVALID_CLIENT_ERROR = "invalid_client"

    attr_reader :result

    def initialize(result)
      @result = result
    end

    def self.authorize(result)
      new(result).authorize
    end

    def self.authorize_token(result)
      new(result).authorize_token
    end

    def authorize
      if invalid_authorization_token_error?
        raise GsExactTargetAuthorizationError, 'invalid or expired auth token'
      elsif invalid_credentials_error?
        raise GsExactTargetAuthorizationError, 'invalid credentials'
      elsif other_error?
        raise GsExactTargetDataError, result
      end
      result
    end

    def authorize_token
      raise GsExactTargetAuthorizationError, 'invalid token response' if invalid_authorization_token?
      authorize
    end

    def other_error?
      result["error"].present? || result["errorcode"].present? || result["error_description"]
    end

    def invalid_authorization_token_error?
      (result["errorcode"] == NOT_AUTHORIZED_ERROR_CODE  && result["message"] == NOT_AUTHORIZED_MESSAGE)
    end

    def invalid_authorization_token?
      ! ( result.has_key?("access_token") && result.has_key?("expires_in") )
    end

    def invalid_credentials_error?
      result["error"] == INVALID_CLIENT_ERROR
    end

  end
end

