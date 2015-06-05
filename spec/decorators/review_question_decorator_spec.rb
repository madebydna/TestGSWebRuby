require 'spec_helper'

describe ReviewQuestionDecorator do
  after do
    clean_models(:gs_schooldb, ReviewQuestion, ReviewTopic)
  end
  describe '#placeholder' do
    context 'with a overall topic question' do
        let(:review_question) { ReviewQuestionDecorator.decorate(FactoryGirl.build(:overall_rating_question)) }
      subject { review_question.placeholder }
      it { is_expected.to eq('Please share why you feel this way.') }
    end
  end
  context 'with an incorrect question id' do
      let(:review_question) { ReviewQuestionDecorator.decorate(FactoryGirl.build(:review_question, id: 999)) }
    subject { review_question.placeholder }
    it { is_expected.to eq('Please share why you feel this way. (Optional. Please do not repeat exact text from another review.)') }
  end
  context 'with a teacher effectiveness question' do
      let(:review_question) { ReviewQuestionDecorator.decorate(FactoryGirl.build(:teacher_question, id: 7)) }
    subject { review_question.placeholder }
    text = 'Please share why you feel this way about teachers. (Optional. Please do not repeat exact text from another review.)'
    it { is_expected.to eq(text) }
  end

end