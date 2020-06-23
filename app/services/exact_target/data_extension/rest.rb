class ExactTarget
  class DataExtension
    class Rest

      def self.perform_call(method, object)
        begin
          uri, payload = RestCalls.send(method, object)
          ExactTarget::ApiInterface.put_json(uri, payload)
        rescue => e
          vars = { method: method, object: object }
          GSLogger.error(:misc, e, message: "Unable to make ExactTarget Rest Call", vars: vars)
          raise
        end
      end

    end
  end
end