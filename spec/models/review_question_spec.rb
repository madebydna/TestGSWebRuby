require 'spec_helper'
require_relative 'examples/model_with_active_field'

describe ReviewQuestion do
  let(:review_question) {FactoryGirl.create(:review_question)}
  let(:overall_question) {FactoryGirl.create(:overall_rating_question)}
  let(:teacher_question) {FactoryGirl.create(:teacher_question)}
  after do
    clean_dbs :gs_schooldb
  end

  after(:each) do
    clean_models :ca, School, TestDataSet, TestDataSchoolValue
  end

  it { is_expected.to be_a(ReviewQuestion) }
  it_behaves_like 'model with active field'


 describe '#level_code_array' do
  it 'should return an array' do
    expect(subject.level_code_array).to be_a(Array)
  end

   it 'should return an array of the level codes' do
     expect(review_question.level_code_array).to eq(%w(p e m h))
   end
 end

 describe '#response_label_array' do
   it 'should return array with response values when not for overall topic' do
     expect(teacher_question.response_label_array).to eq(teacher_question.response_array)
   end

   it 'should return array with star labels for overall topic' do
     label_array = (2..5).map {|n| n.to_s + ' stars'}.unshift('1 star')
     expect(overall_question.response_label_array).to eq(label_array)
   end
 end

  describe '#matches_school?' do
    let(:matching_school) {FactoryGirl.create(:alameda_high_school)}
    let(:not_matching_school1) {FactoryGirl.create(:alameda_high_school, level_code: 'e')}
    let(:not_matching_school2) {FactoryGirl.create(:alameda_high_school, type: 'private')}
    let(:review_question) {FactoryGirl.create(:review_question, school_level: matching_school.level_code, school_type: matching_school.type)}
    it 'should return true if matches school' do
      expect(review_question.matches_school?(matching_school)).to be_truthy
    end
    it 'should return false if it does not match school school level and matches school type' do
      expect(review_question.matches_school?(not_matching_school1)).to be_falsey
    end
    it 'should return false if it does not match school school type and matches school level' do
      expect(review_question.matches_school?(not_matching_school2)).to be_falsey
    end
  end

end
