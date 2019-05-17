require 'spec_helper'
require 'exact_target'

describe ExactTarget do
  it "allows an instance to be instantiated" do
    expect { ExactTarget.new }.to_not raise_error
  end

  it { is_expected.to respond_to(:send_triggered_email) }

  it "captures the triggered send when send_triggered_email is called in test environment" do
    et = ExactTarget.new
    expect(et).to receive(:capture_delivery)
    et.send_triggered_email("foo", "foo@example.com")
  end

  describe '#build_soap_body' do

    it 'adds extra attributes from the soap body' do
      et = ExactTarget.new
      body = et.send(:build_soap_body, 'a_key', 'foo@example.com', {bar: 'test'})
      expect(body[:objects][:subscribers].first[:attributes].first['Name']).to eq(:bar)
      expect(body[:objects][:subscribers].first[:attributes].first['Value']).to eq('test')
    end

    it 'adds cdata to verification link attribute' do
      et = ExactTarget.new
      body = et.send(:build_soap_body, 'a_key', 'foo@example.com', {VERIFICATION_LINK: 'test'})
      expect(body[:objects][:subscribers].first[:attributes].first['Name']).to eq(:VERIFICATION_LINK)
      # The ! here instructs Savon not to escape the value
      expect(body[:objects][:subscribers].first[:attributes].first['Value!']).to eq('<![CDATA[test]]>')
    end

    it 'adds the correct priority' do
      et = ExactTarget.new
      body = et.send(:build_soap_body, 'a_key', 'foo@example.com', {}, nil, 'High')
      expect(body[:options][:queue_priority]).to eq('High')
    end

    it 'adds "from" if provided' do
      et = ExactTarget.new
      body = et.send(
        :build_soap_body,
        'a_key',
        'foo@example.com',
        {},
        {
          name: 'GreatSchools',
          address:'test@greatschools.org'
        }
      )
      puts body.inspect
      expect(body[:objects][:subscribers].first[:owner][:from_address])
        .to eq('test@greatschools.org')
      expect(body[:objects][:subscribers].first[:owner][:from_name])
        .to eq('GreatSchools')
    end

  end

end