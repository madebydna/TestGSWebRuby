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
      # The following two changes get the request looking more like the sample provided by ExactTarget
      element_form_default: :unqualified, # do not attempt to qualify elements with namespace
      namespace_identifier: nil # do not qualify the message body with a namespace
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
    # Special case verification links to wrap them in a CDATA block. Recommendation by ExactTarget support
    # The ! after the element name instructs Savon not to escape the value
    attributes.each do |k,v|
      if k == :VERIFICATION_LINK
        wsdl_attr << {'Name' => k, 'Value!' => "<![CDATA[#{v}]]>"}
      else
        wsdl_attr << {'Name' => k, 'Value' => v}
      end
    end

    # create JSON-like hashes that hold values
    soap_body = {
      options: {
        queue_priority: priority,
        request_type: 'Asynchronous'
      },
      objects: {
        '@xsi:type' => 'TriggeredSend',
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
    # message_tag: Change name of SOAP message tag to CreateRequest -- THIS IS THE MOST IMPORTANT THING
    # attributes: add a namespace to the SOAP message tag -- this is to make the request look more like the sample
    response = client.call(type, message_tag: :CreateRequest, message: body, attributes: {:xmlns => 'http://exacttarget.com/wsdl/partnerAPI'})
  end

  def capture_delivery(hash_of_args)
    self.last_delivery_args = hash_of_args
  end

end