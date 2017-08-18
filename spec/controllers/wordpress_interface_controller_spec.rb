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
        let(:user_session_key) { 'my_session_key' }
        let(:scenario_key)     { 'A1' }
        before do
          FactoryGirl.create(:customer_like, user_session_key: user_session_key, item_key: scenario_key)
          FactoryGirl.create(:customer_like, user_session_key: 'another_key', item_key: scenario_key)
        end
        before do
          post_params.merge!({
                               wp_params: {
                                 user_session_key: user_session_key,
                                 scenario_key: scenario_key,
                               }
                            })
        end

        it 'should return a count of the likes' do
          post :call_from_wordpress, post_params
          json_response = JSON.parse(response.body)
          expect(json_response['total_like_count']).to eql(2)
        end

        it 'should return a count of the user likes' do
          post :call_from_wordpress, post_params
          json_response = JSON.parse(response.body)
          expect(json_response['user_like_count']).to eql(1)
        end

        it 'should only return total likes for that scenario key' do
          other_user_session_key, other_scenario_key = 'other_session_key', 'B2'

          FactoryGirl.create(:customer_like, user_session_key: other_user_session_key, item_key: other_scenario_key)
          FactoryGirl.create(:customer_like, user_session_key: user_session_key, item_key: other_scenario_key)

          post :call_from_wordpress, post_params
          json_response = JSON.parse(response.body)
          expect(json_response['total_like_count']).to eql(2)
        end

        it 'should only return user likes for that scenario key' do
          other_user_session_key, other_scenario_key = 'other_session_key', 'B2'

          FactoryGirl.create(:customer_like, user_session_key: user_session_key, item_key: other_scenario_key)
          FactoryGirl.create(:customer_like, user_session_key: other_user_session_key, item_key: other_scenario_key)

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
      let(:user_session_key) { 'my_session_key' }
      let(:scenario_key)     { 'A1' }

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

      it 'should return a count of likes' do
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

      context 'when a user already has a liked an item' do
        it 'should not let the user like it again' do
          FactoryGirl.create(:customer_like, user_session_key: user_session_key, item_key: scenario_key)

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

      context 'when a user already has a liked a different item' do
        it 'should let the user like the current item' do
          FactoryGirl.create(:customer_like, user_session_key: user_session_key, item_key: 'B2')

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

      context 'when there are other likes already saved' do
        it 'should let the user like the current item' do
          FactoryGirl.create(:customer_like, user_session_key: 'other_user_session', item_key: scenario_key)

          post_params.merge!({
            wp_params: {
              user_session_key: user_session_key,
              scenario_key: scenario_key,
            }
          })

          post :call_from_wordpress, post_params
          json_response = JSON.parse(response.body)
          expect(json_response['total_like_count']).to eql(2)
        end
      end
    end


    describe 'wp_action: newsletter_page_signup' do
      after { clean_dbs :gs_schooldb }
      let(:post_params) { { wp_action: 'newsletter_page_signup', format: :json } }
      let(:user_session_key) { 'my_session_key' }
      let(:state) { 'CA' }
      let(:email) { 'test@greatschools.org' }
      let(:grade) { ['12'] }
      let(:lists) { ['foo'] }

      context 'with valid params' do
        it 'return a valid response' do
          post_params.merge!({
            wp_params: {
              user_session_key: user_session_key,
              state: state,
              email: email,
              grade: grade,
              lists: lists
            }
          })

          post :call_from_wordpress, post_params
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("member_id")
        end
      end

      context 'with missing lists param' do
        it 'return a valid response' do
          post_params.merge!({
            wp_params: {
              user_session_key: user_session_key,
              state: state,
              email: email,
              grade: grade
            }
          })

          post :call_from_wordpress, post_params
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("member_id")
        end
      end
    end

  end

end
