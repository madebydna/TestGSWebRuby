require 'spec_helper'

describe ReviewQuestionDecorator do
  after do
    clean_models(:gs_schooldb, ReviewQuestion, ReviewTopic)
  end
  describe '#placeholder' do
    context 'with a overall topic question' do
      let(:review_question) { ReviewQuestionDecorator.decorate(FactoryGirl.build(:overall_rating_question, id: 1)) }
      subject { review_question.placeholder_text }
      it { is_expected.to eq('Please share why you feel this way. ') }
    end
  end
  context 'with topic not found in key' do
    let(:review_question) { ReviewQuestionDecorator.decorate(FactoryGirl.build(:review_question)) }
    before do
      allow(review_question).to receive_message_chain(:topic, :name).and_return('Blah')
    end
    subject { review_question.placeholder_text }
    it { is_expected.to eq("Please share why you feel this way. \n(Optional. There\'s no need to repeat text from another review.)") }
  end

  placeholder_key = {
      'Honesty' => 'Please share why you feel this way. How do you feel this school develops honesty, integrity, and fairness in students? ',
      'Empathy' => 'Please share why you feel this way. How do you feel this school develops compassion, caring, and empathy in students? ',
      'Respect' => 'Please share why you feel this way. How do you feel this school develops respect in students? ',
      'Grit' => 'Please share why you feel this way. How do you feel this school develops persistence, grit, and determination in students? ',
      'Homework' => 'Please share why you feel this way about homework at this school. ',
      'Teachers' => 'Please share why you feel this way about teachers at this school. '
  }
  placeholder_key.each do |topic_name, text|
    context "with a #{topic_name} question" do
      let(:review_question) { ReviewQuestionDecorator.decorate(FactoryGirl.build(:review_question)) }
      before do
        allow(review_question).to receive_message_chain(:topic, :name).and_return(topic_name)
      end
      subject { review_question.placeholder_text }
      placeholder_text = text + "\n(Optional. There\'s no need to repeat text from another review.)"
      it { is_expected.to eq(placeholder_text) }
    end
  end

end