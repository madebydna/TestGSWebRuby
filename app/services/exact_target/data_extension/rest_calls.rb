class ExactTarget
  class DataExtension
    class RestCalls

      def self.upsert_gbg(subscription)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['gbg_subscriptions']}/rows/id:#{subscription.id}"
        payload = {
          values: {
            member_id: subscription.member_id,
            grade: subscription.grade,
            language: subscription.language,
            district_id: subscription.district_id,
            district_state: subscription.district_state
          }
        }
        [uri, payload]
      end

      def self.upsert_school(school)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['gs_school']}/rows/id:#{school.id}"
        # TODO: we're not sure if we'll need real-time school upserts
      end

      def self.upsert_school_signup(subscription)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['school_sign_up']}/rows/id:#{subscription.id}"
        payload = {
          values: {
            member_id: subscription.member_id,
            state: subscription.state,
            school_id: subscription.school_id,
            language: subscription.language
          }
        }
        [uri, payload]
      end

      def self.upsert_subscription(subscription)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['subscription_list']}/rows/id:#{subscription.id}"
        payload = {
          values: {
            member_id: subscription.member_id,
            list: subscription.list,
            language: subscription.language
          }
        }
        [uri, payload]
      end

      def self.upsert_member(member)
        uri = "/hub/v1/dataevents/key:#{EXTENSIONS_TO_KEYS['members']}/rows/id:#{member.id}"
        payload = {
          values: {
            email: member.email,
            id: member.id,
            updated: member.updated,
            time_added: member.time_added,
            Hash_token: UserVerificationToken.token(member.id),
            how: member.how
          }
        }
        [uri, payload]
      end
    end
  end
end
