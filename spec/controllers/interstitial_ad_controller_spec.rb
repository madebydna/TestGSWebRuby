require 'spec_helper'

describe InterstitialAdController do
  describe '#whitelist_uri' do
    # More detailed specs on the whitelist are in url_utils_spec

    subject { controller.send(:whitelist_uri, uri) }

    describe 'given an empty string' do
      let (:uri) { '' }
      it { is_expected.to eq '/' }
    end

    describe 'given a third party host' do
      let (:uri) { 'http://www.greatschools.org.malicious.cn/account/' }
      it { is_expected.to eq '/' }
    end

    describe 'given a valid production URL' do
      let (:uri) { 'http://www.greatschools.org/account/?flash=success' }
      it { is_expected.to eq uri }
    end
  end
end