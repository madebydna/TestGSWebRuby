require 'fuelsdk'

class ExactTarget
  class EmailSoap
    attr_reader :client

    # See https://help.exacttarget.com/en/technical_library/web_service_guide/error_codes/12000_12099_subscriber_object/
    ERROR_SUBSCRIBER_NOT_FOUND = '12001'
    ERROR_SUBSCRIBER_ALREADY_EXISTS = '12014'

    def initialize
      @client = FuelSDK::Client.new(
          {
              'client' => {
                  'id' => ENV_GLOBAL['exacttarget_v2_api_key'],
                  'secret' => ENV_GLOBAL['exacttarget_v2_api_secret']
              }
          }
      )
    end

    def get_subscriber(email)
      #puts "Retrieving subscriber #{email}"
      call = subscriber_call
      call.filter = filter_on_email(email)
      response = call.get

      process_response(response, {call: :get, subscriber: email}).results.first
    end

    def create_subscriber(user)
      #puts "Creating subscriber #{user.email}"
      call = subscriber_call
      call.props = user_props(user)
      response = call.post

      if subscriber_already_exists?(response)
        update_subscriber(user)
      else
        process_response(response, {call: :create, subscriber: user.email}).success?
      end
    end

    def update_subscriber(user)
      #puts "Updating subscriber #{user.email}"
      call = subscriber_call
      call.props = user_props(user)
      response = call.patch

      if subscriber_does_not_exist?(response)
        response = create_subscriber(user)
      end
      process_response(response, {call: :update, subscriber: user.email}).success?
    end

    def delete_subscriber(email)
      #puts "Deleting subscriber #{email}"
      call = subscriber_call
      call.props = email_props(email)
      response = call.delete

      process_response(response, {call: :delete, subscriber: email}).success?
    end

    private

    def subscriber_does_not_exist?(response)
      response.success == false && error_code(response) == ERROR_SUBSCRIBER_NOT_FOUND
    end

    def subscriber_already_exists?(response)
      response.success == false && error_code(response) == ERROR_SUBSCRIBER_ALREADY_EXISTS
    end

    def error_code(response)
      if response && response.results.present? && response.results[0].has_key?(:error_code)
        response.results[0][:error_code]
      else
        nil
      end
    end

    def subscriber_call
      call = FuelSDK::Subscriber.new
      call.authStub = @client
      call
    end

    def process_response(response, opt_vars = {})
      unless response.success?
        GSLogger.error(:exact_target, nil, vars:
                                        {error_code: response.results[0][:error_code], message: response.results[0][:status_message]}.merge(opt_vars),
                       message: 'Error connecting to ExactTarget')
      end
      response
    end

    def filter_on_email(email)
      {'Property' => 'EmailAddress', 'SimpleOperator' => 'equals', 'Value' => email}
    end

    def email_props(email)
      {'EmailAddress' => email}
    end

    def user_props(user)
      {'EmailAddress' => user.email, 'member_id' => user.id, 'email_verified' => user.email_verified,
       'time_added' => user.time_added, 'updated' => user.updated}
    end
  end
end