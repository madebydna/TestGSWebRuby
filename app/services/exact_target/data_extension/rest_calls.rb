class ExactTarget
  class DataExtension
    class RestCalls

      def self.upsert_gbg(access_token, subscription)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['gbg_subscriptions']}/rows/id:#{subscription.id}"
        payload = {
          values: {
            member_id: subscription.member_id,
            grade: subscription.grade,
            language: 'en'
          }
        }
        ApiInterface.new.put_json_with_auth(uri, payload, access_token)
      end

      def self.upsert_school(access_token, school)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['gs_school']}/rows/id:#{school.id}"
        # TODO: we're not sure if we'll need real-time school upserts
      end

      def self.upsert_school_signup(access_token, subscription)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['school_sign_up']}/rows/id:#{subscription.id}"
        payload = {
          values: {
            member_id: subscription.member_id,
            state: subscription.state,
            school_id: subscription.school_id,
            language: 'en'
          }
        }
        ApiInterface.new.put_json_with_auth(uri, payload, access_token)
      end

      def self.upsert_subscription(access_token, subscription)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['subscription_list']}/rows/id:#{subscription.id}"
        payload = {
          values: {
            member_id: subscription.member_id,
            list: subscription.list,
            language: 'en'
          }
        }
        ApiInterface.new.put_json_with_auth(uri, payload, access_token)
      end


      # def contact_subscriptions(access_token, phone_numbers)
      #   uri = '/sms/v1/contacts/subscriptions'
      #   # /data/v1/async/dataextensions/{id}/rows
      #   # /data/v1/async/dataextensions/key:{key}/rows
      #   # can take an array of numbers
      #   mobile_contact = {"mobileNumber" => phone_numbers}
      #   ExactTarget::ApiInterface.new.post_json_with_auth(uri, mobile_contact, access_token)
      # end

      # def create_mobile_contact(access_token, phone_number, attributes = nil)
      #   # /data/v1/async/dataextensions/{id}/rows
      #   # /data/v1/async/dataextensions/key:{key}/rows
      #   uri = '/contacts/v1/contacts'
      #   mobile_contacts_hash = ExactTarget::MobileContactsHashService.create(phone_number, attributes)
      #   ExactTarget::ApiInterface.new.post_json_with_auth(uri, mobile_contacts_hash, access_token)
      # end

      # def update_mobile_contact(access_token, phone_number, attributes)
      #   uri = '/contacts/v1/contacts'
      #   mobile_contacts_hash = ExactTarget::MobileContactsHashService.create(phone_number, attributes)
      #   ExactTarget::ApiInterface.new.patch_json_with_auth(uri, mobile_contacts_hash, access_token)
      # end
    end
  end
end
