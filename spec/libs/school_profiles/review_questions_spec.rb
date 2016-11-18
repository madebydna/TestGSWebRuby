require "spec_helper"

describe SchoolProfiles::ReviewQuestions do
  after(:each) do
    clean_dbs(:gs_schooldb)
  end
  let(:alameda_high_school) { FactoryGirl.create(:alameda_high_school) }
  subject do
    SchoolProfiles::ReviewQuestions.new(alameda_high_school)
  end
  after do
    clean_dbs :ca
  end

  describe "#questions" do
    it "should return array of hashes for only active questions" do
      five_star_review_question = create(:overall_rating_question, active: 1)
      teacher_question = create(:review_question, active: 1)
      inactive_question = create(:review_question, active: 0)

      expect(subject.questions.count).to eq(2)
      expect(subject.questions.map.all?{ |q| q.is_a?(Hash)}).to eq(true)
    end

    it "should return correct hash for five star review question" do
      five_star_question = create(:overall_rating_question, active: 1)
      five_star_response_labels = %w(Terrible Bad Average Good Great)
      result_hash = {
        response_values: five_star_question.response_array,
        response_labels: five_star_response_labels,
        layout: five_star_question.layout,
        title: five_star_question.question,
        id: five_star_question.id,
      }
      expect(subject.questions.first).to eq(result_hash)
    end

    it "should return correct hash for question where response labels match the values" do
      topical_review_question = create(:review_question, active: 1)
      expect(I18n).to receive(:t).with(topical_review_question.question, anything).and_return(topical_review_question.question)
      result_hash = {
        response_values: topical_review_question.response_array,
        response_labels: topical_review_question.response_array,
        layout: topical_review_question.layout,
        title: topical_review_question.question,
        id: topical_review_question.id,
      }
      expect(subject.questions.first).to eq(result_hash)
    end
  end
end

