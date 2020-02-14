class ExactTarget
  module SmsRest
    attr_reader :auth_token_manager
    def initialize
      @sms_rest_calls = ExactTarget::SmsRestCalls.new
      @auth_token_manager = ExactTarget::AuthTokenManager
      ExactTarget::SmsRestCalls.instance_methods(false).each { |method_name|  SmsRest.define_rest_method(method_name) }
    end

    def self.define_rest_method(method_name)
      define_method(method_name) do |*args|
        access_token = auth_token_manager.fetch_access_token
        begin
          begin
            result = @sms_rest_calls.send(method_name, access_token, *args)
          rescue GsExactTargetAuthorizationError
            access_token = auth_token_manager.fetch_new_access_token
            result = @sms_rest_calls.send(method_name, access_token, *args)
          end
        rescue GsExactTargetAuthorizationError => e
          vars = {method_name: method_name, args: args }
          GSLogger.error(:misc, e, message: "Unable to make ExactTarget Sms Rest Call", vars: vars)
          raise e
        end
        result
      end
    end
  end
end
