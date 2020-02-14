class ExactTarget
  class DataExtension
    class SoapCalls

      def self.delete(key, object, client)
        de_object = {
          '@xsi:type' => "tns:DataExtensionObject",
          'CustomerKey' => key,
          'Keys' => [{ 'Key' => [{ 'Name' => 'id', 'Value' => object.id }]}]
        }
        client.call(:delete, message: {'Objects' => de_object, attributes: {'xsi:type' => "DataExtensionObject" } })
      end

    end

  end
end