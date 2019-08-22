require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require 'features/page_objects/school_profile_reviews_page'
require 'features/contexts/shared_contexts_for_signed_in_users'


shared_context 'with 2 questions: first an overall star topic question; second a radio button question' do
  # create topics- requires that a school was set by previous context
  let(:overall_topic) { FactoryBot.create(:overall_topic, school_level: school.level_code, school_type: school.type, id: 1) }
  let(:teachers_topic) { FactoryBot.create(:teachers_topic, school_level: school.level_code, school_type: school.type) }
  # create questions for topic
  # Execute immediately
  let!(:overall_rating_question) { FactoryBot.create(:overall_rating_question, review_topic: overall_topic ) }
  let!(:teacher_question) { FactoryBot.create(:teacher_question) }

  after do
    clean_models ReviewTopic, ReviewQuestion
  end
end

shared_context 'a radio button question' do
  # create topics- requires that a school was set by previous context
  let(:teachers_topic) { FactoryBot.create(:teachers_topic, school_level: school.level_code, school_type: school.type) }
  # create questions for topic
  # Execute immediately
  let!(:teacher_question) { FactoryBot.create(:teacher_question, review_topic: teachers_topic) }
  after do
    clean_models ReviewTopic, ReviewQuestion
  end
end

shared_context 'with signing up for a new account' do
  before do
    pending ('Replace this context with when_I sign up via modal for new account. Keep all assertions.')
    fail
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
    pending ('Replace this context with when_I sign up via modal for signin into verified account.')
    fail
    click_link('Login')
    user = FactoryBot.create(:verified_user)
    log_in_user(user)
    fill_in(:email, with: user.email)
    fill_in(:password, with: user.password)
    click_button('Login')
    current_url
  end
  after do
    log_out_user
    clean_models User
  end
end

shared_context 'with signing into a verified account without role for school' do
  before do
    pending ('update sign in with modal with verified account without role for school')
    fail
    click_link('Login')
    user = FactoryBot.create(:verified_user)
    log_in_user(user)
    fill_in(:email, with: user.email)
    fill_in(:password, with: user.password)
    click_button('Login')
    current_url
  end
  after do
    log_out_user
    clean_models User, SchoolUser
  end
end

shared_context 'with signing into a verified account with role for school' do
  let(:user) do
    FactoryBot.create(:verified_user)
  end
  let!(:school_user) do
    FactoryBot.create(:parent_school_user, school: school, user: user)
  end
  before do
    pending ('update with signing into verified account through modal')
    fail
    click_link('Login')
    # user = FactoryBot.create(:verified_user)
    log_in_user(user)
    fill_in(:email, with: user.email)
    fill_in(:password, with: user.password)
    click_button('Login')
    current_url
  end
  after do
    log_out_user
    clean_models User, SchoolUser
  end
end

shared_context 'signed in verified user with role for school' do
  let(:user) do
    FactoryBot.create(:verified_user)
  end
  let!(:school_user) do
    FactoryBot.create(:parent_school_user, school: school, user: user)
  end

  before do
    log_in_user(user)
  end

  after do
    log_out_user
    clean_models User, SchoolUser
  end
end

shared_context 'with signed in as principal for school' do
  let(:user) do
    FactoryBot.create(:verified_user)
  end
  let!(:school_user) do
    FactoryBot.create(:principal_school_user, school: school, user: user)
  end

  before do
    log_in_user(user)
  end

  after do
    log_out_user
    clean_models User, SchoolUser
  end
end

shared_context 'click third star' do
  before do
    response_option = subject.active_slide.stars[2]
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
    first('input').click
    first(:button, 'Submit').click
    wait_for_ajax
    wait_for_page_to_finish
    subject.wait_for_active_topic_2_question_aria
  end
end

shared_context 'with two active reviews' do
  let!(:two_active_reviews) do
    [
      FactoryBot.create(:five_star_review, active: true, school: school),
      FactoryBot.create(:teacher_effectiveness_review, active: true, school: school)
    ]
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolUser
  end
end

shared_context 'an overall principal review' do
  let!(:overall_principal_review) do
    review = FactoryBot.create(:five_star_review, active: true, school: school)
    FactoryBot.create(:principal_school_user, school: review.school, user: review.user)
    review
  end
end

shared_context 'a topical principal review' do
  let!(:topical_principal_review) do
    review = FactoryBot.create(:teacher_effectiveness_review, active: true, school: school)
    FactoryBot.create(:principal_school_user, school: review.school, user: review.user)
    review
  end
end

shared_context 'with seven parent reviews' do
  let!(:seven_parent_reviews) do
    reviews = FactoryBot.create_list(:five_star_review, 7, active: true, school: school)
    reviews.each do |review|
      FactoryBot.create(:parent_school_user, school: review.school, user: review.user)
    end
    reviews
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolUser
  end
end

shared_context 'with seven student reviews' do
  let!(:seven_student_reviews) do
    reviews = FactoryBot.create_list(:five_star_review, 7, active: true, school: school)
    reviews.each do |review|
      FactoryBot.create(:student_school_user, school: review.school, user: review.user)
    end
    reviews
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolUser
  end
end



shared_context 'with seven parent overall reviews' do
  let!(:overall_question) do
    FactoryBot.create(:overall_rating_question)
  end
  # let!(:review_answer) do
  #   FactoryBot.build(:review_answer_overall)
  # end
  let!(:seven_parent_reviews) do
    reviews = FactoryBot.create_list(:five_star_review, 7, active: true, school: school, question: overall_question)
    reviews.each do |review|
      FactoryBot.create(:parent_school_user, school: review.school, user: review.user)
      # FactoryBot.create(:review_answer_overall, review: review)
    end
    reviews
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolUser
  end
end


shared_context 'with seven student teacher effectiveness reviews' do
  let!(:teacher_question) do
    FactoryBot.create(:teacher_question)
  end
  let!(:seven_student_reviews) do
    reviews = FactoryBot.create_list(:teacher_effectiveness_review, 7, active: true, school: school, question: teacher_question )
    reviews.each do |review|
      FactoryBot.create(:student_school_user, school: review.school, user: review.user)
      # FactoryBot.create(:review_answer_teacher, review: review)
    end
    reviews
  end
  after do
    clean_models Review, ReviewQuestion, ReviewTopic, ReviewAnswer, SchoolUser
  end
end

shared_context 'with active review' do
  let!(:active_review) do
    FactoryBot.create(:five_star_review, active: true, school: school)
  end
  after do
    clean_dbs :gs_schooldb
  end
end

shared_context 'with active review with one vote' do
  let!(:active_review_with_one_vote) do
    review = FactoryBot.create(:five_star_review, active: true, school: school)
    FactoryBot.create(:review_vote, review: review)
    review
  end
  after do
    clean_dbs :gs_schooldb
  end
end

shared_context 'with inactive review' do
  let!(:inactive_review) do
    FactoryBot.create(:five_star_review, active: false, school: school, comment: 'inactive review inactive review inactive review inactive review inactive review inactive review inactive review inactive review inactive review inactive review')
  end
  after do
    clean_dbs :gs_schooldb
  end
end

shared_context 'with five star review' do
  let!(:five_star_review) do
    FactoryBot.create(:five_star_review, active: true, school: school)
  end
  after do
    clean_dbs :gs_schooldb
  end
end

shared_context 'with topical review' do
  let!(:topical_review) do
    FactoryBot.create(:teacher_effectiveness_review, active: true, school: school)
  end
  after do
    clean_dbs :gs_schooldb
  end
end
