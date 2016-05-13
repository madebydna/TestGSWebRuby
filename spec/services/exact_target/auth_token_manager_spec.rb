require 'spec_helper'
require 'exact_target'

describe ExactTarget::AuthTokenManager do
  before do
    pending('TODO: add new shared cache table to database')
    fail
  end
  after do
    clean_dbs(:gs_schooldb, :shared_cache)
  end

  describe '#fetch_access_token' do
    subject { ExactTarget::AuthTokenManager.fetch_access_token }
    context 'with access token in database' do
      it 'should return access token from database' do
        stub_shared_cache_with_token_in_database
        expect(subject).to eq('stuff')
      end
    end

    context 'with access token not in database' do
      before do
        stub_shared_cache_with_no_token_in_database
        Timecop.freeze(Time.local(1990))
      end
      after do
         Timecop.return
      end

      context 'with valid access token response from exact target' do
        before do
          stub_exact_target_api_interface_to_return_valid_token
        end
        it 'should return access token from exact target access hash' do
          expect(subject).to eq('token')
        end
        it 'should save access token in shared cache with correct expiration time' do
          expect(SharedCache).to receive(:set_cache_value).
            with('et_rest_access_token', 'token', time_expires_result)
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
      stub_shared_cache_with_no_token_in_database
      Timecop.freeze(Time.local(1990))
    end
    after do
      Timecop.return
    end

    context 'with valid access token response from exact target' do
      before do
        stub_exact_target_api_interface_to_return_valid_token
      end
      it 'should return access token from exact target access hash' do
        expect(subject).to eq('token')
      end
      it 'should save access token in shared cache with correct expiration time' do
        expect(SharedCache).to receive(:set_cache_value).
          with('et_rest_access_token', 'token', time_expires_result)
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
    d =  Time.now
    d += (3600 - 30).seconds
    d.strftime('%Y-%m-%d %H:%M:%S')
  end

  def stub_exact_target_api_interface_to_return_invalid_token
    exact_target_api = double
    allow(ExactTarget::ApiInterface).to receive(:new).and_return(exact_target_api)
    allow(exact_target_api).to receive(:post_auth_token_request).
      and_return({})
  end

  def stub_exact_target_api_interface_to_return_valid_token
    valid_token_response = {
      'accessToken' => 'token',
      'expiresIn' => '3600' 
    }
    exact_target_api = double
    allow(ExactTarget::ApiInterface).to receive(:new).and_return(exact_target_api)
    allow(exact_target_api).to receive(:post_auth_token_request).
      and_return(valid_token_response)
  end


  def stub_shared_cache_with_token_in_database
    db_access_token = 'stuff' 
    allow(SharedCache).to receive(:get_cache_value).and_return(db_access_token)
  end

  def stub_shared_cache_with_no_token_in_database
    allow(SharedCache).to receive(:get_cache_value).and_return(nil)
  end

end
