require 'spec_helper'
describe Api::NearbySchoolsController do
  render_views

  it { is_expected.to respond_to(:show) }

  describe '#show' do
    after do
      clean_dbs :gs_schooldb, :ca
    end

    context 'with no schools' do
      it 'should return an empty response' do
        school = FactoryGirl.create(:school)
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
          FactoryGirl.create(
            :school,
            name: 'school a',
            lat: 37.7647364,
            lon: -122.2470357
          ),
          FactoryGirl.create(
            :school,
            name: 'school b',
            lat: 37.7647365,
            lon: -122.2470358
          ),
          FactoryGirl.create(
            :school,
            name: 'school c',
            lat: 37.7647366,
            lon: -122.2470359
          )
        ]
      end
      let(:nearby_schools) { schools[1..-1] }
      let(:school) { schools.first }

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
        stub_const('Api::NearbySchoolsController::MAX_LIMIT', 1)
        get :show, state: school.state, id: school.id, limit: 2
        response_array = JSON.parse(response.body)
        expect(response_array.size).to eq(1)
      end

      context 'when schools have reviews' do
        before { give_reviews_to_schools(schools) }
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
  end

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
