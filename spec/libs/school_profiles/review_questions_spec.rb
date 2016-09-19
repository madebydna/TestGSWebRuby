require "spec_helper"

describe SchoolProfiles::ReviewQuestions do
  after do
    clean_dbs(:gs_schooldb)
  end

  describe "#five_star_review_question" do
    it "should return five star review question" do
      five_star_review_question = create(:overall_rating_question, id: 1)
      expect(subject.five_star_review_question).to eq(five_star_review_question)
    end
  end

  describe "#topical_questions" do
    it "not should return five star review question" do
      five_star_review_question = create(:overall_rating_question, id: 1, active: 1)
      teacher_question = create(:teacher_question, id: 2, active: 1)

      expect(subject.topical_questions.count).to eq(1)
      expect(subject.topical_questions.first).to eq(teacher_question)
    end
  end
end

