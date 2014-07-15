require 'savon'

class ExactTarget
  cattr_accessor :last_delivery_args

  def initialize
    @client = Savon.client(
      wsdl: ENV_GLOBAL['exacttarget_wsdl'],
      ssl_verify_mode: :none,
      wsse_auth: [
        ENV_GLOBAL['exacttarget_api_key'],
        ENV_GLOBAL['exacttarget_api_secret'],
      ],
      convert_request_keys_to: :camelcase,
      namespaces: {
        'xmlns:tns' => 'http://exacttarget.com/wsdl/partnerAPI'
      }
    )
  end

  def available_actions
    @client.wsdl.soap_actions
  end

  def client
    @client
  end

  def options
    @options
  end

  def send_triggered_email(key, recipient, attributes = {}, from = nil, priority = 'Medium')
    if Rails.env.test?
      capture_delivery(
        key: key,
        recipient: recipient,
        attributes: attributes,
        from: from,
        priority: priority
      )
    else
      soap_body = build_soap_body(key, recipient, attributes, from, priority)
      send_request(:create, soap_body)
    end
  end

  private

  def build_soap_body(key, recipient, attributes = {}, from = nil, priority = 'Medium')
    # convert rest to wsdl:Attributes Name fields
    wsdl_attr = []
    attributes.each { |k,v| wsdl_attr << {'Name' => k, 'Value' => v} }

    # create JSON-like hashes that hold values
    soap_body = {
      options: {
        queue_priority: priority
      },
      objects: {
        '@xsi:type' => 'tns:TriggeredSend',
        triggered_send_definition: {
          customer_key: key
        },
        subscribers: {
          email_address: recipient,
          subscriber_key: recipient,
          attributes: wsdl_attr
        },
      }
    }

    if from.present?
      soap_body[:objects][:subscribers][:owner] = {
        from_address: from[:address],
        from_name: from[:name]
      }
    end
    soap_body
  end

  def send_request(type, body)
    response = client.call(type, message: body)
  end

  def capture_delivery(hash_of_args)
    self.last_delivery_args = hash_of_args
  end

end