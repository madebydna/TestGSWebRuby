require 'spec_helper'

describe 'Reviews API' do
  before(:all) do
    head '/'
    puts '*' * 100
    @csrf_token = request.cookie_jar.fetch(:csrf_token)
  end

  def get(path, hash={})
    super(path, hash, { 'X-CSRF-Token' => @csrf_token })
  end

  let(:json) { JSON.parse(response.body) }
  let(:count) { JSON.parse(response.body)['result'] }
  let(:status) { response.status }
  let(:errors) { json['errors'] }

  after { clean_dbs :gs_schooldb, :ca }

  describe '#count' do
    it 'handles case where no reviews in db and no filters given' do
      get '/gsr/api/reviews/count', format: :json
      expect(status).to eq(200)
      expect(errors).to be_nil
      expect(count).to eq(0)
    end

    it 'handles case where no reviews in db and some filters given' do
      get '/gsr/api/reviews/count', format: :json, fields: %w[answer_value], review_question_id: 1
      expect(status).to eq(200)
      expect(errors).to be_nil
      expect(count).to eq({})
    end

    it 'handles no filters or group' do
      create(:five_star_review, state: 'AK', review_question_id: 1, answer_value: 'Yes')
      create(:five_star_review, state: 'AK', review_question_id: 1, answer_value: 'Yes')
      create(:five_star_review, state: 'AK', review_question_id: 1, answer_value: 'No')
      create(:five_star_review, state: 'AR', review_question_id: 1, answer_value: 'No')

      get '/gsr/api/reviews/count', format: :json
      expect(status).to eq(200)
      expect(errors).to be_nil
      expect(count).to eq(4)
    end

    it 'handles grouping' do
      create_review({answer_value: 'Yes'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'Yes'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'No'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'No'}, state: 'AK', review_question_id: 1)

      get '/gsr/api/reviews/count', format: :json, fields: %w[answer_value]
      expect(status).to eq(200)
      expect(errors).to be_nil
      expect(count).to eq({
        'Yes' => 2,
        'No' => 2
      })
    end

    it 'handles grouping and filtering' do
      create_review({answer_value: 'Yes'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'Yes'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'No'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'No'}, state: 'AK', review_question_id: 2)

      get '/gsr/api/reviews/count', format: :json, fields: %w[answer_value], review_question_id: 1
      expect(status).to eq(200)
      expect(errors).to be_nil
      expect(count).to eq({
        'Yes' => 2,
        'No' => 1
      })
    end

    it 'ignores non allowed fields' do
      create_review({answer_value: 'Yes'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'Yes'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'No'}, state: 'AK', review_question_id: 1)
      create_review({answer_value: 'No'}, state: 'AK', review_question_id: 2)

      get '/gsr/api/reviews/count', format: :json, fields: %w[comment foobar]
      expect(status).to eq(200)
      expect(count).to eq(4)
    end
  end

  describe '#index' do
    let(:reviews) { json['items'] }

    it 'Returns some reviews' do
      school = create(:alameda_high_school)
      create(:five_star_review, state: school.state, school_id: school.id)

      get '/gsr/api/reviews/', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(reviews.length).to eq(1)
    end

    it 'does not find inactive review' do
      school = create(:alameda_high_school)
      create(:five_star_review, state: school.state, school_id: school.id, active: false)

      get '/gsr/api/reviews/', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(reviews).to be_blank
    end

    it 'Obeys limit param' do
      school = create(:alameda_high_school)
      2.times do
        create(:five_star_review, state: school.state, school_id: school.id, active: true)
      end
      get '/gsr/api/reviews/?limit=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(reviews.length).to eq(1)
    end

    it 'Obeys offset param' do
      school = create(:alameda_high_school)
      2.times do
        create(:five_star_review, state: school.state, school_id: school.id, active: true)
      end

      get '/gsr/api/reviews/?offset=1', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(reviews.length).to eq(1)
    end

    it 'Filters on review_question_id' do
      school = create(:alameda_high_school)
      create(:five_star_review, state: school.state, school_id: school.id, active: true, review_question_id: 98)
      create(:five_star_review, state: school.state, school_id: school.id, active: true, review_question_id: 99)

      get '/gsr/api/reviews/?review_question_id=99', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(reviews.length).to eq(1)
    end

    it 'Filters on state' do
      create(:five_star_review, state: 'AK', school_id: 1, active: true)
      create(:five_star_review, state: 'AL', school_id: 1, active: true)

      get '/gsr/api/reviews/?state=ak', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(reviews.length).to eq(1)
    end

    it 'Filters on school_id' do
      create(:five_star_review, state: 'AK', school_id: 1, active: true)
      create(:five_star_review, state: 'AK', school_id: 2, active: true)

      get '/gsr/api/reviews/?school_id=2', format: :json
      expect(status).to eq(200)
      expect(errors).to be_blank
      expect(reviews.length).to eq(1)
    end
  end
end

def create_review(answer_props, **props)
  r = create(:review, **props)
  create(:review_answer, review_id: r.id, **answer_props)
end

