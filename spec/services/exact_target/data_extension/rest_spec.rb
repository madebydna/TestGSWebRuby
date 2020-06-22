require 'spec_helper'

describe ExactTarget::DataExtension::Rest do
  let(:object) { double(id: 1, member_id: 100, grade: 5) }


  describe '.perform_call' do
    it 'will retry access token retrieval' do
      allow(ExactTarget::AuthTokenManager).to receive(:fetch_access_token)\
        .and_return("expired_token")
      expect(ExactTarget::AuthTokenManager).to receive(:fetch_new_access_token)\
      .and_return("123456ABC")

      allow(ExactTarget::DataExtension::RestCalls).to \
        receive(:upsert_gbg).with("expired_token", object).and_raise(GsExactTargetAuthorizationError, 'invalid or expired auth token')
      expect(ExactTarget::DataExtension::RestCalls).to \
        receive(:upsert_gbg).with("123456ABC", object).and_return({"some" => "body"})

      expect { |b| ExactTarget::DataExtension::Rest.perform_call_with_fallback(&b) }.to \
        yield_with_args("expired_token")

      # TODO: figure out how to test for second yield
      #expect { |b| ExactTarget::DataExtension::Rest.perform_call_with_fallback(&b) }.to \
      #  yield_with_args("123456ABC")

      ExactTarget::DataExtension::Rest.perform_call(:upsert_gbg, object)
    end

    context 'with no error from REST call' do
      before do
        allow(ExactTarget::AuthTokenManager).to receive(:fetch_access_token)\
          .and_return("123456ABC")
        allow(ExactTarget::DataExtension::RestCalls).to \
          receive(:upsert_gbg).with("123456ABC", object).and_return({"some" => "body"})
      end

      it "should not raise error" do
        expect {
          ExactTarget::DataExtension::Rest.perform_call(:upsert_gbg, object)
        }.not_to raise_error
      end

      it "should return value from REST call" do
        expect(ExactTarget::DataExtension::Rest.perform_call(:upsert_gbg, object)).to eq({"some" => "body"})
      end
    end

    context 'with error from REST call' do
      let(:expected_error) { GsExactTargetDataError.new("something went wrong")}

      before do
        allow(ExactTarget::AuthTokenManager).to receive(:fetch_access_token)\
          .and_return("123456ABC")
        allow(ExactTarget::DataExtension::RestCalls).to \
          receive(:upsert_gbg).with("123456ABC", object).and_raise(expected_error)
      end

      it 'should log and re-raise error' do
        expect(GSLogger).to receive(:error).with(:misc, \
          expected_error, message: "Unable to make ExactTarget Rest Call", \
          vars: { method: :upsert_gbg, object: object})
        expect {
          ExactTarget::DataExtension::Rest.perform_call(:upsert_gbg, object)
        }.to raise_error(expected_error)
      end

    end

  end
end