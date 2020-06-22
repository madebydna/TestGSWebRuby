require "spec_helper"
require "savon/mock/spec_helper"

describe ExactTarget::DataExtension::Soap do
  include Savon::SpecHelper

  before(:all) { savon.mock! }
  after(:all) { savon.unmock! }
  let(:key) { '123' }
  let(:object) { double(id: 1) }
  let(:fixture_success) { File.read("spec/fixtures/soap_delete_de_success.xml") }
  let(:fixture_error) { File.read("spec/fixtures/soap_fault_security.xml") }
  let(:message) {
    {"Objects"=>{"@xsi:type"=>"tns:DataExtensionObject",
      "CustomerKey"=>key, "Keys"=>[{"Key"=>[{"Name"=>"id", "Value"=>object.id}]}]},
      :attributes=>{"xsi:type"=>"DataExtensionObject"}}
  }

  describe '.perform_call' do

    it 'will retry access token retrieval' do
      allow(ExactTarget::AuthTokenManager).to receive(:fetch_access_token)\
        .and_return("expired_token")
      expect(ExactTarget::AuthTokenManager).to receive(:fetch_new_access_token)\
        .and_return("123456ABC")

      savon.expects(:delete).with(message: message).returns(fixture_error)
      savon.expects(:delete).with(message: message).returns(fixture_success)

      expect(ExactTarget::DataExtension::Soap).to receive(:build_client).with(no_args).and_call_original
      expect(ExactTarget::DataExtension::Soap).to receive(:build_client).with(token: "123456ABC").and_call_original

      ExactTarget::DataExtension::Soap.perform_call(:delete, key, object)
    end

    context 'with error from SOAP call' do
      before do
        allow(ExactTarget::AuthTokenManager).to receive(:fetch_access_token)\
          .and_return("123456ABC")
        de_delete_error = File.read("spec/fixtures/soap_delete_de_error.xml")
        savon.expects(:delete).with(message: message).returns(de_delete_error)
      end

      it 'should log and re-raise error' do
        expect(GSLogger).to receive(:error).with(:misc, \
          instance_of(GsExactTargetDataError), message: "Unable to make ExactTarget Soap Call", \
          vars: { method: :delete, object: object})
        expect {
          ExactTarget::DataExtension::Soap.perform_call(:delete, key, object)
        }.to raise_error(GsExactTargetDataError, "Duplicate/Invalid field found.")
      end
    end

    context 'with no error from SOAP call' do
      before do
        allow(ExactTarget::AuthTokenManager).to receive(:fetch_access_token)\
          .and_return("123456ABC")
        savon.expects(:delete).with(message: message).returns(fixture_success)
      end

      it "should not raise error" do
        expect {
          ExactTarget::DataExtension::Soap.perform_call(:delete, key, object)
        }.not_to raise_error
      end

      it "should return value from REST call" do
        savon_response = ExactTarget::DataExtension::Soap.perform_call(:delete, key, object)
        expect(savon_response.http.body).to eq(fixture_success)
      end
    end
  end
end