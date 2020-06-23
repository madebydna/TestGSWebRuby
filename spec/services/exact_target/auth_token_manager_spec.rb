require 'spec_helper'
require 'exact_target'

describe ExactTarget::AuthTokenManager do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe '#fetch_access_token' do
    subject { ExactTarget::AuthTokenManager.fetch_access_token }
    context 'with access token in Rails cache' do
      it 'should return access token from database' do
        stub_cache_with_token
        expect(subject).to eq('stuff')
      end
    end

    context 'with access token not in Rails cache' do
      before do
        stub_cache_with_no_token
      end

      context 'with valid access token response from exact target' do
        before do
          stub_exact_target_api_interface_to_return_valid_token
        end
        it 'should return access token from exact target access hash' do
          expect(subject).to eq('token')
        end
        it 'should save access token in cache with correct expiration time' do
          expect(memory_store).to receive(:write).
            with('et_rest_access_token', 'token', expires_in: time_expires_result)
          subject
        end
      end

      context 'with access token not present in access hash from exact target' do
        it 'should return nil' do
          stub_exact_target_api_interface_to_return_invalid_token
          expect(subject).to eq(nil)
        end
      end
    end
  end

  describe '#fetch_new_access_token' do
    subject { ExactTarget::AuthTokenManager.fetch_new_access_token }
    before do
      stub_cache_with_no_token
    end

    context 'with valid access token response from exact target' do
      before do
        stub_exact_target_api_interface_to_return_valid_token
      end
      it 'should return access token from exact target access hash' do
        expect(subject).to eq('token')
      end
      it 'should save access token in cache with correct expiration time' do
        expect(memory_store).to receive(:write).
          with('et_rest_access_token', 'token', hash_including(expires_in: time_expires_result))
        subject
      end
    end

    context 'with access token not present in access hash from exact target' do
      it 'should return nil' do
        stub_exact_target_api_interface_to_return_invalid_token
        expect(subject).to eq(nil)
      end
    end
  end

  def time_expires_result
    (3600 - 30).seconds
  end

  def stub_exact_target_api_interface_to_return_invalid_token
    allow(ExactTarget::ApiInterface).to receive(:post_auth_token_request).
      and_return({})
  end

  def stub_exact_target_api_interface_to_return_valid_token
    valid_token_response = {
      'access_token' => 'token',
      'expires_in' => '3600'
    }
    allow(ExactTarget::ApiInterface).to receive(:post_auth_token_request).
      and_return(valid_token_response)
  end


  def stub_cache_with_token
    db_access_token = 'stuff'
    allow(memory_store).to receive(:read).and_return(db_access_token)
  end

  def stub_cache_with_no_token
    allow(memory_store).to receive(:read).and_return(nil)
  end

end
