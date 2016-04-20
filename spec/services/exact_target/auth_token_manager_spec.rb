require 'spec_helper'
require 'exact_target'

describe ExactTarget::AuthTokenManager do
  after do
    clean_dbs(:gs_schooldb, :shared_cache)
  end
  let(:auth_token_class) { Class.new.extend(ExactTarget::AuthTokenManager) }
  describe '#fetch_access_token' do
    subject { auth_token_class.fetch_access_token }
    context 'with access token in database' do
      let (:shared_cache) { class_double('SharedCache') }
      before do
        stub_const('SharedCache', shared_cache)
        allow(shared_cache).to receive(:get_cache_value).and_return(db_access_token)
      end
      let(:db_access_token) { 'stuff' }
      it 'should return access token from database' do
        expect(subject).to eq('stuff')
      end
    end

    context 'with access token not in database' do
      let(:db_access_token) { nil }
      let(:rest_credentials) { {} }
      let(:exact_target_api) { class_double('ExactTarget::ApiInterface') }
      let!(:time_now) { Time.parse('1/1/2000','7:00') }
      before do
        allow(auth_token_class).to receive(:credentials_rest).and_return({})
        stub_const('ExactTarget::ApiInterface', exact_target_api)
        allow(exact_target_api).to receive(:post_json_get_auth).
          with(rest_credentials).and_return(exact_target_access_hash)
        allow(Time).to receive(:now).and_return(time_now)
        allow(SharedCache).to receive(:get_cache_value).and_return(db_access_token)
      end

      context 'with access token present in access hash from exact target' do
        let(:exact_target_access_hash) do
          {'accessToken' => 'token',
           'expiresIn' => '3600' }
        end
        let(:time_expires_result) do
          d =  time_now
          d += (3600 - 30).seconds
          d.strftime('%Y-%m-%d %H:%M:%S')
        end
        context 'with access token set in database' do
          it 'should return access token from exact target access hash' do
            expect(subject).to eq('token')
          end
          it 'should save access token in shared cache with correct expiration time' do
            expect(SharedCache).to receive(:set_cache_value).with('et_rest_access_token', 'token', time_expires_result)
            subject
          end
        end

        context 'with access token not set in database' do
          it 'should return access token from exact target access hash' do
            expect(subject).to eq('token')
          end
        end
      end

      context 'with access token not present in access hash from exact target' do
# What does the ExactTarget::ApiInterface return if there is a failure?
        let(:exact_target_access_hash) { {} }
        it 'should return nil' do
          expect(subject).to eq(nil)
        end
      end
    end
  end
end
