class ExactTarget
  class DataExtension
    class SoapCalls

      def self.delete(key, object, client)
        de_object = {
          '@xsi:type' => "tns:DataExtensionObject",
          'CustomerKey' => key,
          'Keys' => [{ 'Key' => [{ 'Name' => 'id', 'Value' => object.id }]}]
        }
        response = client.call(:delete, message: {'Objects' => de_object, attributes: {'xsi:type' => "DataExtensionObject" } })
        if delete_error?(response)
          raise GsExactTargetDataError, response.body.dig(:delete_response, :results, :status_message)
        else
          response
        end
      end


      def self.delete_error?(response)
        response.body.dig(:delete_response, :results, :status_code) == "Error"
      end

    end
  end
end