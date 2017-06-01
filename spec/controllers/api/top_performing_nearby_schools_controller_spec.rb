require 'spec_helper'
describe Api::TopPerformingNearbySchoolsController do
  render_views

  it { is_expected.to respond_to(:show) }

  describe '#show' do
    after do
      clean_dbs :gs_schooldb, :ca
    end

    context 'with no schools' do
      before do
        expect(SchoolSearchService).to receive(:by_location).and_return({
          num_results: 0,
          start: 0,
          results: []
        })
      end

      it 'should return an empty response' do
        school = FactoryGirl.create(
          :school,
          name: 'school a',
          lat: 37.7647364,
          lon: -122.2470357
        )
        get :show, state: school.state, id: school.id
        expect(JSON.parse(response.body)).to be_empty
      end
    end

    it 'when not given school should return 404' do
      get :show
      expect(response.status).to be(404)
    end

    context 'with nearby schools' do
      let(:schools) do
        [
          FactoryGirl.build(
            :school_search_result,
            id: 1,
            name: 'school a',
            city: 'alameda',
            state: 'ca',
            review_count: 2,
            community_rating: 3.0
          ),
          FactoryGirl.build(
            :school_search_result,
            id: 2,
            name: 'school b',
            city: 'alameda',
            state: 'ca',
            review_count: 2,
            community_rating: 3.0
          ),
          FactoryGirl.build(
            :school_search_result,
            id: 3,
            name: 'school c',
            city: 'alameda',
            state: 'ca',
            review_count: 2,
            community_rating: 3.0
          )
        ]
      end
      let(:nearby_schools) { schools[1..-1] }
      let(:school) do
        FactoryGirl.create(
          :school,
          name: 'school a',
          lat: 37.7647364,
          lon: -122.2470357
        )
      end

      before do
        expect(SchoolSearchService).to receive(:by_location).and_return({
          num_results: 3,
          start: 0,
          results: schools
        })
      end

      it 'should return a 200 status code' do
        get :show, state: school.state, id: school.id
        expect(response.status).to eq(200)
      end

      it 'should render the nearby schools' do
        get :show, state: school.state, id: school.id
        response_array = JSON.parse(response.body)
        expect(response_array).to be_present

        nearby_schools.each do |nearby_school|
          expect(
            response_array.find do |hash|
              {
                'name' => nearby_school.name,
                'state' => nearby_school.state
              }.to_a - hash.to_a
            end
          ).to be_present
        end
      end

      it 'obeys the limit param' do
        get :show, state: school.state, id: school.id, limit: 1
        response_array = JSON.parse(response.body)
        expect(response_array.size).to eq(1)
      end

      it 'obeys the max limit' do
        stub_const('Api::TopPerformingNearbySchoolsController::MAX_LIMIT', 1)
        get :show, state: school.state, id: school.id, limit: 2
        response_array = JSON.parse(response.body)
        expect(response_array.size).to eq(1)
      end

      it 'contains the school\'s url' do
        get :show, state: school.state, id: school.id, limit: 2
        response_array = JSON.parse(response.body)
        expect(response_array.first).to have_key('links')
        expect(response_array.first['links']['show']).to be_present
      end

      it 'contain number_of_reviews and average_rating in each response' do
        get :show, state: school.state, id: school.id
        response_array = JSON.parse(response.body)
        expect(response_array).to be_present
        response_array.each do |hash|
          expect(hash).to have_key('number_of_reviews')
          expect(hash).to have_key('average_rating')
          expect(hash['number_of_reviews']).to be(2)
          expect(hash['average_rating']).to be(3.0)
        end
      end
      
    end
  end

  # def make_nearby_school_caches(school, nearby_schools)
  #   closest_top_then_top_nearby_schools =
  #     nearby_schools.map.with_index do |s, index|
  #       {
  #         "city" => s.city,
  #         "distance" => index,
  #         "id" => s.id,
  #         "name" => s.name,
  #         "state" => s.state,
  #         "number_of_reviews" => 2,
  #         "average_rating" => 3.0
  #       }
  #     end
  #   FactoryGirl.create(
  #     :nearby_schools,
  #     school_id: school.id,
  #     state: school.state,
  #     value: {
  #       "closest_top_then_top_nearby_schools" => closest_top_then_top_nearby_schools
  #     }.to_json
  #   )
  # end

  def give_reviews_to_schools(schools)
    schools.each do |s|
      FactoryGirl.create(
        :five_star_review,
        state: s.state,
        school_id: s.id,
        review_question_id: 1,
        answer_value: 1
      )
      FactoryGirl.create(
        :five_star_review,
        state: s.state,
        school_id: s.id,
        review_question_id: 1,
        answer_value: 5
      )
    end
  end
end
