class ExactTarget
  class DataExtension
    class Rest

      # def initialize
      #   @sms_rest_calls = ExactTarget::SmsRestCalls.new
      #   @auth_token_manager = ExactTarget::AuthTokenManager
      #   ExactTarget::SmsRestCalls.instance_methods(false).each { |method_name|  SmsRest.define_rest_method(method_name) }
      # end

      def self.perform_call(method, object)
        begin
          perform_call_with_fallback do |access_token|
            RestCalls.send(method, access_token, object)
          end
        rescue StandardError => e
          vars = { method: method, object: object }
          GSLogger.error(:misc, e, message: "Unable to make ExactTarget Rest Call", vars: vars)
          raise e
        end
      end

      def self.perform_call_with_fallback
        access_token = ExactTarget::AuthTokenManager.fetch_access_token
        begin
          yield access_token
        rescue GsExactTargetAuthorizationError
          access_token = ExactTarget::AuthTokenManager.fetch_new_access_token
          yield access_token
        end
      end

      # def self.define_rest_method(method_name)
      #   define_method(method_name) do |*args|
      #     access_token = auth_token_manager.fetch_access_token
      #     begin
      #       begin
      #         result = @sms_rest_calls.send(method_name, access_token, *args)
      #       rescue GsExactTargetAuthorizationError
      #         access_token = auth_token_manager.fetch_new_access_token
      #         result = @sms_rest_calls.send(method_name, access_token, *args)
      #       end
      #     rescue GsExactTargetAuthorizationError => e
      #       vars = {method_name: method_name, args: args }
      #       GSLogger.error(:misc, e, message: "Unable to make ExactTarget Sms Rest Call", vars: vars)
      #       raise e
      #     end
      #     result
      #   end
      # end

    end
  end
end