class ExactTarget
  class SmsRest

    def initialize
      @sms_rest_calls = ExactTarget::SmsRestCalls.new
      define_all_methods
    end

    def define_all_methods
      ExactTarget::SmsRestCalls.instance_methods(false).each do |method_name|
        # @sms_rest_calls.methods.each do |method_name|
        define_method(method_name) do
          access_token = ExactTarget::AuthTokenManager.fetch_accesstoken
          result = @sms_rest_calls.send(method_name, access_token, args)
          if (!ExactTarget::AuthTokenManager.authentication_verify(result))
            result = @sms_rest_calls.send(method_name, access_token, args)
          end
          result
        end
      end
    end

    # def method_missing(method_name, *args)
    #   super if !@sms_rest_calls.respond_to? method_name
    #   access_token = ExactTarget::AuthTokenManager.fetch_accesstoken
    #   result = @sms_rest_calls.send(method_name, access_token, args)
    #   if(!ExactTarget::AuthTokenManager.authentication_verify(result))
    #     result = @sms_rest_calls.send(method_name, access_token, args)
    #   end
    #   result
    # end
    #
    # def respond_to_missing? (method_name, include_private = false)
    #   @sms_rest_calls.respond_to?(method_name) || super
    # end

  end
end