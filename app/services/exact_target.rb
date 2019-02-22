require 'savon'

class ExactTarget
  cattr_accessor :last_delivery_args

  # Sample observer
  # class SavonObserver
  #   def notify(operation_name, builder, globals, locals)
  #     puts builder.to_s # Dump raw XML of SOAP request
  #     nil
  #   end
  # end

  def initialize
    # Savon.observers << SavonObserver.new
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
      namespace_identifier: nil, # do not qualify the message body with a namespace
      open_timeout: 10,
      read_timeout: 10
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
    recipients = Array.wrap(recipient)
    if Rails.env.test?
      capture_delivery(
        key: key,
        recipient: recipient,
        attributes: attributes,
        from: from,
        priority: priority
      )
    else
      final_recipients = is_live_server? ? recipients : recipients.select(&method(:internal_recipient?))
      if final_recipients.size < recipients.size
        Rails.logger.debug("Suppressing delivery to #{recipients.size - final_recipients.size} recipient(s) because I am not running on www")
      end
      soap_body = build_soap_body(key, final_recipients, attributes, from, priority)
      send_request(:create, soap_body)
    end
  end

  private

  def is_live_server?
    ENV_GLOBAL['app_host'] =~ /www\.greatschools\.org/
  end

  def internal_recipient?(recipient)
    recipient =~ /@greatschools\.(org|net)/
  end

  def build_soap_body(key, recipients, attributes = {}, from = nil, priority = 'Medium')
    # convert rest to wsdl:Attributes Name fields
    wsdl_attr = attributes.map do |k,v|
      # Special case verification links to wrap them in a CDATA block. Recommendation by ExactTarget support
      # The ! after the element name instructs Savon not to escape the value
      if k == :VERIFICATION_LINK
        {'Name' => k, 'Value!' => "<![CDATA[#{v}]]>"}
      else
        {'Name' => k, 'Value' => v}
      end
    end

    subscriber_hash_array = Array.wrap(recipients).map do |email|
      {
          email_address: email,
          subscriber_key: email,
          attributes: wsdl_attr
      }.tap do |h|
        if from.present?
          h[:owner] = {
              from_address: from[:address],
              from_name: from[:name]
          }
        end
      end
    end

    # create JSON-like hashes that hold values
    {
      options: {
        queue_priority: priority,
        request_type: 'Asynchronous'
      },
      objects: {
        '@xsi:type' => 'TriggeredSend',
        triggered_send_definition: {
          customer_key: key
        },
        subscribers: subscriber_hash_array,
      }
    }
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