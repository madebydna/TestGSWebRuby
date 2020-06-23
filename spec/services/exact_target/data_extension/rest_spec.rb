require 'spec_helper'

describe ExactTarget::DataExtension::Rest do
  let(:object) { double(id: 1, member_id: 100, grade: 5, language: 'es') }


  describe '.perform_call' do
    let(:example_uri) { "https://exacttarget.resturi.com" }
    let(:example_payload) { { "some" => "body" } }
    let(:example_response) { {"some" => "response" } }

    before do
      allow(ExactTarget::DataExtension::RestCalls).to \
      receive(:upsert_gbg).with(object).and_return([example_uri, example_payload])
    end

    context 'with no error from REST call' do
      before do
        expect(ExactTarget::ApiInterface).to receive(:put_json).with(example_uri, example_payload).and_return(example_response)
      end

      it "should not raise error" do
        expect {
          ExactTarget::DataExtension::Rest.perform_call(:upsert_gbg, object)
        }.not_to raise_error
      end

      it "should return value from REST call" do
        expect(ExactTarget::DataExtension::Rest.perform_call(:upsert_gbg, object)).to eq(example_response)
      end
    end

    context 'with error from REST call' do
      let(:expected_error) { GsExactTargetDataError.new("something went wrong")}

      before do
        allow(ExactTarget::ApiInterface).to receive(:put_json).with(example_uri, example_payload).and_raise(expected_error)
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