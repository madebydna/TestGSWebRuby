require 'spec_helper'

describe SchoolUserController do

  describe '#create' do
    let(:school) { FactoryGirl.build(:alameda_high_school) }
    let(:school_user) { FactoryGirl.build(:teacher_school_user, school: school) }
    let(:user) { FactoryGirl.build(:verified_user) }

    before do
      controller.instance_variable_set(:@school, school)
      allow(controller).to receive(:require_school).and_return(school)
      allow(controller).to receive(:find_or_initialize_school_user).and_return(school_user)
      controller.instance_variable_set(:@current_user, user)
    end
    after do
      clean_models(:gs_schooldb, SchoolUser)
    end

    [SchoolUser::Affiliation::PRINCIPAL, SchoolUser::Affiliation::STUDENT].each do |type|
      context "when school member is a #{type}" do
        it 'should handle user\'s saved reviews' do
          expect(school_user).to receive(:handle_saved_reviews_for_students_and_principals)
          xhr :post, :create,
              state: States.state_name(school.state),
              schoolId: school.id,
              city: school.city,
              school_name: school.name,
              school_user: { user_type: type.to_s }
        end
      end
    end

    context 'when school member is saved successfully' do
      before do
        allow(school_user).to receive(:save).and_return(true)
        allow(user).to receive(:send_thank_you_email_for_school)
      end
      it 'should return status ok' do
        xhr :post, :create,
            state: States.state_name(school.state),
            schoolId: school.id,
            city: school.city,
            school_name: school.name,
            school_user: { user_type: 'parent' }
        expect(response.status).to eq(200)
      end
    end

  end

  describe '#find_or_initialize_school_user' do
    let(:user) { FactoryGirl.build(:verified_user) }
    let(:school) { FactoryGirl.build(:alameda_high_school) }
    let(:school_user) { FactoryGirl.build(:parent_school_user, user: user, school: school) }
    before do
      allow(controller).to receive(:logged_in?).and_return true
      allow(controller).to receive(:current_user).and_return user
      controller.instance_variable_set(:@school, school)
    end
    context 'with no existing SchoolUser' do
      before do
        allow(SchoolUser).to receive(:find_by_school_and_user).and_return nil
      end
      it 'should build a SchoolUser' do
        expect(controller.find_or_initialize_school_user).to be_a(SchoolUser)
      end
    end
    context 'with an existing SchoolUser' do
      before do
        allow(SchoolUser).to receive(:find_by_school_and_user).and_return school_user
      end
      it 'should build a SchoolUser' do
        expect(controller.find_or_initialize_school_user).to be(school_user)
      end
    end
    context 'when not logged in' do
      before do
        allow(controller).to receive(:logged_in?).and_return false
      end
      it 'raises an exception' do
        expect { controller.find_or_initialize_school_user }.to raise_exception(Exception, 'User not logged in')
      end
    end
    context 'when school is not set' do
      before do
        controller.instance_variable_set(:@school, nil)
      end
      it 'raises an exception' do
        expect { controller.find_or_initialize_school_user }.to raise_exception(Exception, 'Current school is unknown')
      end
    end
  end

end