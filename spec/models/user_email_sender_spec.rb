require 'spec_helper'

shared_example 'should not send email' do
  expect(subject.send_thank_you_email?(school_user)).to be_falsey
end

shared_example 'should send email' do
  expect(subject.send_thank_you_email?(school_user)).to be_truthy
end

shared_context 'with one active review' do
  before do
    allow(school_user).to receive_message_chain(:active_reviews, :count).and_return(1)
  end
end

describe UserEmailSender do
  let(:user) { FactoryGirl.build(:user) }
  subject {UserEmailSender.new(user)}

  describe '#send_thank_you_email_for_school' do
    let(:school) { FactoryGirl.build(:school) }
    context 'with email to be sent' do
      before do
        allow(subject).to receive(:send_thank_you_email?).and_return(true)
        allow(subject).to receive(:school_reviews_url).with(school).and_return('blah')
      end
      it 'should send email' do
        expect(ThankYouForReviewEmail).to receive(:deliver_to_user).with(user, school, 'blah')
        subject.send_thank_you_email_for_school(school)
      end
      context 'with email to not be sent' do
        before do
          allow(subject).to receive(:send_thank_you_email?).and_return(false)
          allow(subject).to receive(:school_reviews_url).with(school).and_return('blah')
        end
        it 'should not send email' do
          expect(ThankYouForReviewEmail).to_not receive(:deliver_to_user).with(user, school, 'blah')
          subject.send_thank_you_email_for_school(school)
        end
      end
    end
  end

  describe '#send_thank_you_email?' do
    context 'with no school user' do
      let(:school_user) { nil }
      include_example 'should not send email'
    end
    with_shared_context 'with one active review' do
      context 'with unknown school user for user' do
        let(:school_user) { FactoryGirl.build(:unknown_school_user) }
        include_example 'should not send email'
      end

      ['parent', 'student', 'teacher', 'principal', 'community'].each do |member_type|
        context "with #{member_type} type" do
          let(:school_user) { FactoryGirl.build("#{member_type}_school_user".to_sym) }
          include_example 'should send email'
        end
      end
    end

    context 'with no active reviews' do
      before do
        allow(school_user).to receive_message_chain(:active_reviews, :count).and_return(0)
      end
      ['parent', 'student', 'teacher', 'principal', 'community', 'unknown'].each do |member_type|
        context "with #{member_type} type" do
          let(:school_user) { FactoryGirl.build("#{member_type}_school_user".to_sym) }
          include_example 'should not send email'
        end
      end
    end

    context 'with more than one active' do
      before do
        allow(school_user).to receive_message_chain(:active_reviews, :count).and_return(2)
      end
      ['parent', 'student', 'teacher', 'principal', 'community'].each do |member_type|
        context "with #{member_type} type" do
          let(:school_user) { FactoryGirl.build("#{member_type}_school_user".to_sym) }
          include_example 'should not send email'
        end
      end
    end
  end
end
