class ExactTarget
  class DataExtension
    class SoapCalls

      def self.delete(key, client, ids)
        de_objects = ids.map do |id|
          {
            '@xsi:type' => "tns:DataExtensionObject",
            'CustomerKey' => key,
            'Keys' => [{ 'Key' => [{ 'Name' => 'id', 'Value' => id }]}]
          }
        end
        response = client.call(:delete, message: {'Objects' => de_objects, attributes: {'xsi:type' => "DataExtensionObject" } })
        errors = extract_delete_errors(response)
        if errors.any?
          messages = errors.map do |error|
            "\"#{error[:error_message]}\" for #{error[:object][:keys]}"
          end
          raise GsExactTargetDataError, messages.join("; ")
        else
          response
        end
      end

      def self.extract_delete_errors(response)
        results = Array.wrap(response.body.dig(:delete_response, :results))
        results.select {|result| result[:status_code] == "Error" }
      end

      def self.retrieve(de_name, client, filter, requested_properties = ['id'])
        filter = {
          '@xsi:type' => 'SimpleFilterPart',
          'Property' => filter[:property],
          'SimpleOperator' => filter[:operator],
          'Value' => filter[:value]
        }
        message = {
          'RetrieveRequest' => {
            'ObjectType' => "DataExtensionObject[#{de_name}]",
            'Filter' => filter,
            'Properties' => requested_properties
          }
        }
        response = client.call(:retrieve, message: message).body
        if response[:retrieve_response_msg][:overall_status] != "OK"
          raise GsExactTargetDataError, response[:retrieve_response_msg][:overall_status]
        elsif response[:retrieve_response_msg][:overall_status] == "OK"
          extract_retrieve_results(response)
        else
          raise GsExactTargetDataError, response
        end
      end

      def self.extract_retrieve_results(response)
        Array.wrap(response[:retrieve_response_msg][:results]).map do |result|
          hash = {}
          Array.wrap(result[:properties][:property]).map do |property|
            hash[property[:name]] = property[:value]
          end
          hash
        end
      end


      # <soapenv:Body>
      # <RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">
      # <RetrieveRequest>
      # <ObjectType>DataExtensionObject[Example DE]</ObjectType>
      # <Properties>EMAIL_ADDRESS</Properties>
      # <Properties>CUSTOMER_ID</Properties>
      # <Properties>FIRST_NAME</Properties>
      # <Properties>SITE_GROUP</Properties>
      # <Filter xsi:type="SimpleFilterPart">
      # <Property>EMAIL_ADDRESS</Property>
      # <SimpleOperator>equals</SimpleOperator>
      # <Value>acruz@example.com</Value>
      # </Filter>
      # </RetrieveRequest>
      # </RetrieveRequestMsg>
      # </soapenv:Body>

    end
  end
end