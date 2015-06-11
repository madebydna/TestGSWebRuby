require 'spec_helper'

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
    context 'with one active review' do
      before do
        allow(school_user).to receive_message_chain(:active_reviews, :count).and_return(1)
      end
      context 'with student school_user' do
        let(:school_user) { FactoryGirl.build(:student_school_user) }
        context 'with review with comment present' do
          before do
            allow(school_user).to receive_message_chain(:active_reviews, :first, :comment, :present?).
                                        and_return(true)
          end
          it 'should not send email' do
            expect(subject.send_thank_you_email?(school_user)).to be_falsey
          end
        end
        context 'with review without  comment present' do
          before do
            allow(school_user).to receive_message_chain(:active_reviews, :first, :comment, :present?).
                                        and_return(false)
          end
          it 'should send email' do
            expect(subject.send_thank_you_email?(school_user)).to be_truthy
          end
        end
      end
    end
    context 'with no active reviews' do
      before do
        allow(school_user).to receive_message_chain(:active_reviews, :count).and_return(0)
      end
      ['parent', 'student', 'teacher', 'principal', 'community'].each do |member_type|
        context "with #{member_type} type" do
          let(:school_user) { FactoryGirl.build("#{member_type}_school_user".to_sym) }
          it 'should not send email' do
            expect(subject.send_thank_you_email?(school_user)).to be_falsey
          end
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
          it 'should not send email' do
            expect(subject.send_thank_you_email?(school_user)).to be_falsey
          end
        end
      end
    end
  end
end
