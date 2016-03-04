require 'spec_helper'

describe WordpressInterfaceController do

  describe '#call_from_wordpress' do

    describe 'wp_action: get_like_count' do
      before { clean_models CustomerLike }
      after  { clean_models CustomerLike }
      let(:post_params) { { wp_action: 'get_like_count', format: :json } }

      it 'should return a json object with user_like_count and total_like_count' do
        post_params.merge!({
          wp_params: {
            user_session_key: 'my_session_key',
            scenario_key: 'A1',
          }
        })

        post :call_from_wordpress, post_params
        json_response = JSON.parse(response.body)
        expect(json_response).to include('user_like_count', 'total_like_count')
      end

      context 'when there are active likes for a item' do
        it 'should return a count of those likes' do
          user_session_key, scenario_key = 'my_session_key', 'A1'

          post_params.merge!({
                               wp_params: {
                                 user_session_key: user_session_key,
                                 scenario_key: scenario_key,
                               }
                            })

          FactoryGirl.create(:customer_like, user_session_key: user_session_key, item_key: scenario_key)
          FactoryGirl.create(:customer_like, user_session_key: 'another_key', item_key: scenario_key)

          post :call_from_wordpress, post_params
          json_response = JSON.parse(response.body)
          expect(json_response['total_like_count']).to eql(2)
        end

        it 'should return a count of those user likes' do
          user_session_key, scenario_key = 'my_session_key', 'A1'

          post_params.merge!({
            wp_params: {
              user_session_key: user_session_key,
              scenario_key: scenario_key,
            }
          })

          FactoryGirl.create(:customer_like, user_session_key: user_session_key, item_key: scenario_key)
          FactoryGirl.create(:customer_like, user_session_key: 'another_key', item_key: scenario_key)

          post :call_from_wordpress, post_params
          json_response = JSON.parse(response.body)
          expect(json_response['user_like_count']).to eql(1)
        end

      end
    end

    describe 'wp_action: post_like_count' do
      before { clean_models CustomerLike }
      after  { clean_models CustomerLike }
      let(:post_params) { { wp_action: 'post_like', format: :json } }

      it 'should return a json object with total_like_count' do
        post_params.merge!({
          wp_params: {
            user_session_key: 'my_session_key',
            scenario_key: 'A1',
          }
        })

        post :call_from_wordpress, post_params
        json_response = JSON.parse(response.body)
        expect(json_response).to include('total_like_count')
      end

      it 'should save and return a count of those likes' do
        user_session_key, scenario_key = 'my_session_key', 'A1'

        post_params.merge!({
          wp_params: {
            user_session_key: user_session_key,
            scenario_key: scenario_key,
          }
        })

        post :call_from_wordpress, post_params
        json_response = JSON.parse(response.body)
        expect(json_response['total_like_count']).to eql(1)
      end
    end

  end

end
