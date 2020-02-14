class ExactTarget
  class DataExtension
    class Soap
      WSDL = "#{ENV_GLOBAL['exacttarget_v2_api_soap_uri']}/etframework.wsdl"

      def self.perform_call(method, key, object)
        client = build_client
        SoapCalls.send(method, key, object, client)
      end

      def self.build_client
        Savon.client(
          wsdl: WSDL,
          soap_header: {
            "fueloauth" => AuthTokenManager.fetch_access_token
          },
          pretty_print_xml: true,
          log: true)
      end

    end
  end
end