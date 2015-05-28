require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require_relative '../pages/school_profile_reviews_page'
require 'support/shared_contexts_for_signed_in_users'


shared_context 'with 2 questions: first an overall star topic question; second a radio button question' do
  # create topics- requires that a school was set by previous context
  let(:overall_topic) { FactoryGirl.create(:overall_topic, school_level: school.level_code, school_type: school.type, id: 1) }
  let(:teachers_topic) { FactoryGirl.create(:teachers_topic, school_level: school.level_code, school_type: school.type, id: 2) }
  # create questions for topic
  # Execute immediately
  let!(:overall_rating_question) { FactoryGirl.create(:overall_rating_question, review_topic: overall_topic ) }
  let!(:teacher_question) { FactoryGirl.create(:teacher_question, review_topic: teachers_topic) }

  after do
    clean_models ReviewTopic, ReviewQuestion
  end
end

shared_context 'a radio button question' do
  # create topics- requires that a school was set by previous context
  let(:teachers_topic) { FactoryGirl.create(:teachers_topic, school_level: school.level_code, school_type: school.type) }
  # create questions for topic
  # Execute immediately
  let!(:teacher_question) { FactoryGirl.create(:teacher_question, review_topic: teachers_topic) }
  after do
    clean_models ReviewTopic, ReviewQuestion
  end
end

shared_context 'with signing up for a new account' do
  before do
    fill_in(:email, with: 'test@greatschools.org')
    check('terms[terms]')
    click_button('Sign Up')
    current_url
  end
  after do
    clean_models User
  end
end

shared_context 'with signing into a verified account' do
  before do
    click_link('Login')
    user = FactoryGirl.create(:verified_user)
    log_in_user(user)
    fill_in(:email, with: user.email)
    fill_in(:password, with: user.password)
    click_button('Login')
    current_url
  end
  after do
    clean_models User
  end
end

shared_context 'with signing into a verified account without role for school' do
  before do
    click_link('Login')
    user = FactoryGirl.create(:verified_user)
    log_in_user(user)
    fill_in(:email, with: user.email)
    fill_in(:password, with: user.password)
    click_button('Login')
    current_url
  end
  after do
    clean_models User, SchoolMember
  end
end

shared_context 'with signing into a verified account with role for school' do
  let(:user) do
    FactoryGirl.create(:verified_user)
  end
  let!(:school_member) do
    FactoryGirl.create(:parent_school_member, school: school, user: user)
  end
  before do
    click_link('Login')
    # user = FactoryGirl.create(:verified_user)
    log_in_user(user)
    fill_in(:email, with: user.email)
    fill_in(:password, with: user.password)
    click_button('Login')
    current_url
  end
  after do
    clean_models User, SchoolMember
  end
end

shared_context 'signed in verified user with role for school' do
  let(:user) do
    FactoryGirl.create(:verified_user)
  end
  let!(:school_member) do
    FactoryGirl.create(:parent_school_member, school: school, user: user)
  end

  before do
    log_in_user(user)
  end

  after do
    clean_models User, SchoolMember
  end
end

shared_context 'with signed in as principal for school' do
  let(:user) do
    FactoryGirl.create(:verified_user)
  end
  let!(:school_member) do
    FactoryGirl.create(:principal_school_member, school: school, user: user)
  end

  before do
    log_in_user(user)
  end

  after do
    clean_models User, SchoolMember
  end
end

shared_context 'click third star' do
  before do
    response_option = subject.visible_review_question.stars[2]
    response_option.click
  end
end

shared_context 'select first radio button option' do
 before do
   response_option = subject.visible_review_question.radio_buttons.first
   response_option.click
 end
end

shared_context 'select parent role' do
  before do
    pending ('fails randomly')
    fail
    first('input').click
    first(:button, 'Submit').click
    wait_for_ajax
    wait_for_page_to_finish
    subject.wait_for_active_topic_2_question_aria
  end
end

shared_context 'submit response with comment without bad words' do
  before do
    pending ('fails randomly')
    fail
    comment = 'lorem ' * 15
    subject.visible_review_question.review_comment.fill_in('review[comment]',with: comment)
    question_submit = subject.visible_review_question.submit_button
    question_submit.click
    wait_for_ajax
  end
end

shared_context 'submit response with bad word' do
  before do
    pending ('fails randomly')
    fail
    AlertWord.create!( word: 'test_really_bad_word', really_bad: true )
    comment = 'lorem ' * 15 + 'test_really_bad_word'
    subject.visible_review_question.review_comment.fill_in('review[comment]',with: comment)
    question_submit = subject.visible_review_question.submit_button
    question_submit.click
    wait_for_ajax
  end
end

shared_context 'with two active reviews' do
  let!(:two_active_reviews) do
    [
      FactoryGirl.create(:five_star_review, active: true, school: school),
      FactoryGirl.create(:teacher_effectiveness_review, active: true, school: school)
    ]
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolMember
  end
end

shared_context 'an overall principal review' do
  let!(:overall_principal_review) do
    review = FactoryGirl.create(:five_star_review, active: true, school: school)
    FactoryGirl.create(:principal_school_member, school: review.school, user: review.user)
    review
  end
end

shared_context 'a topical principal review' do
  let!(:topical_principal_review) do
    review = FactoryGirl.create(:teacher_effectiveness_review, active: true, school: school)
    FactoryGirl.create(:principal_school_member, school: review.school, user: review.user)
    review
  end
end

shared_context 'with seven parent reviews' do
  let!(:seven_parent_reviews) do
    reviews = FactoryGirl.create_list(:five_star_review, 7, active: true, school: school)
    reviews.each do |review|
      FactoryGirl.create(:parent_school_member, school: review.school, user: review.user)
    end
    reviews
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolMember
  end
end

shared_context 'with seven student reviews' do
  let!(:seven_student_reviews) do
    reviews = FactoryGirl.create_list(:five_star_review, 7, active: true, school: school)
    reviews.each do |review|
      FactoryGirl.create(:student_school_member, school: review.school, user: review.user)
    end
    reviews
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolMember
  end
end



shared_context 'with seven parent overall reviews' do
  let!(:overall_question) do
    FactoryGirl.create(:overall_rating_question)
  end
  # let!(:review_answer) do
  #   FactoryGirl.build(:review_answer_overall)
  # end
  let!(:seven_parent_reviews) do
    reviews = FactoryGirl.create_list(:five_star_review, 7, active: true, school: school, question: overall_question)
    reviews.each do |review|
      FactoryGirl.create(:parent_school_member, school: review.school, user: review.user)
      # FactoryGirl.create(:review_answer_overall, review: review)
    end
    reviews
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolMember
  end
end


shared_context 'with seven student teacher effectiveness reviews' do
  let!(:teacher_question) do
    FactoryGirl.create(:teacher_question)
  end
  let!(:seven_student_reviews) do
    reviews = FactoryGirl.create_list(:teacher_effectiveness_review, 7, active: true, school: school, question: teacher_question )
    reviews.each do |review|
      FactoryGirl.create(:student_school_member, school: review.school, user: review.user)
      # FactoryGirl.create(:review_answer_teacher, review: review)
    end
    reviews
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolMember
  end
end

shared_context 'with active review' do
  let!(:active_review) do
    FactoryGirl.create(:five_star_review, active: true, school: school)
  end
  after do
    clean_dbs :gs_schooldb
  end
end

shared_context 'with active review with one vote' do
  let!(:active_review_with_one_vote) do
    review = FactoryGirl.create(:five_star_review, active: true, school: school)
    FactoryGirl.create(:review_vote, review: review)
    review
  end
  after do
    clean_dbs :gs_schooldb
  end
end

shared_context 'with inactive review' do
  let!(:inactive_review) do
    FactoryGirl.create(:five_star_review, active: false, school: school, comment: 'inactive review inactive review inactive review inactive review inactive review inactive review inactive review inactive review inactive review inactive review')
  end
  after do
    clean_dbs :gs_schooldb
  end
end

shared_context 'with five star review' do
  let!(:five_star_review) do
    FactoryGirl.create(:five_star_review, active: true, school: school)
  end
  after do
    clean_dbs :gs_schooldb
  end
end

shared_context 'with topical review' do
  let!(:topical_review) do
    FactoryGirl.create(:teacher_effectiveness_review, active: true, school: school)
  end
  after do
    clean_dbs :gs_schooldb
  end
end
