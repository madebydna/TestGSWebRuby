class ExactTarget
  class DataExtension
    class Soap
      WSDL = Rails.env.test? ? nil : "#{ENV_GLOBAL['exacttarget_v2_api_soap_uri']}etframework.wsdl"

      def self.perform_call(method, key, *args)
        begin
          perform_call_with_fallback do |client|
            response = SoapCalls.send(method, key, client, *args)
          end
        rescue StandardError => e
          vars = { method: method, object: args }
          GSLogger.error(:misc, e, message: "Unable to make ExactTarget SOAP Call", vars: vars)
          raise e
        end
      end

      def self.perform_call_with_fallback
        client = build_client
        begin
          yield client
        rescue Savon::SOAPFault => error
          if error.to_hash[:fault][:faultcode] == "q0:Security"
            client = build_client(token: AuthTokenManager.fetch_new_access_token)
            yield client
          else
            raise error
          end
        end
      end

      def self.build_client(token: nil)
        token ||= AuthTokenManager.fetch_access_token
        Savon.client(
          wsdl: WSDL,
          soap_header: {
            fueloauth: token
          },
          namespaces: {
            "xmlns" => "http://exacttarget.com/wsdl/partnerAPI"
          },
          pretty_print_xml: true,
          logger: Rails.logger,
          log: true)
      end
    end
  end
end