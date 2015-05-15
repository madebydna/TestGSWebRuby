require 'spec_helper'

describe SchoolUserController do

  describe '#create' do
    let(:school) { FactoryGirl.build(:alameda_high_school) }
    let(:school_member) { FactoryGirl.build(:teacher_school_member, school: school) }
    before do
      controller.instance_variable_set(:@school, school)
      allow(controller).to receive(:require_school).and_return(school)
      allow(controller).to receive(:find_or_initialize_school_user).and_return(school_member)
    end

    [SchoolMember::Affiliation::PRINCIPAL, SchoolMember::Affiliation::STUDENT].each do |type|
      context "when school member is a #{type}" do
        it 'should deactivate user\'s reviews' do
          expect(school_member).to receive(:deactivate_reviews!)
          xhr :post, :create,
              state: States.state_name(school.state),
              schoolId: school.id,
              city: school.city,
              school_name: school.name,
              school_member: { user_type: type.to_s }
        end
      end
    end

    context 'when school member is saved successfully' do
      before do
        allow(school_member).to receive(:save).and_return(true)
      end
      it 'should return status ok' do
        xhr :post, :create,
            state: States.state_name(school.state),
            schoolId: school.id,
            city: school.city,
            school_name: school.name,
            school_member: { user_type: 'parent' }
        expect(response.status).to eq(200)
      end
    end

  end

  describe '#find_or_initialize_school_user' do
    let(:user) { FactoryGirl.build(:verified_user) }
    let(:school) { FactoryGirl.build(:alameda_high_school) }
    let(:school_member) { FactoryGirl.build(:parent_school_member, user: user, school: school) }
    before do
      allow(controller).to receive(:logged_in?).and_return true
      allow(controller).to receive(:current_user).and_return user
      controller.instance_variable_set(:@school, school)
    end
    context 'with no existing SchoolUser' do
      before do
        allow(SchoolMember).to receive(:find_by_school_and_user).and_return nil
      end
      it 'should build a SchoolUser' do
        expect(controller.find_or_initialize_school_user).to be_a(SchoolMember)
      end
    end
    context 'with an existing SchoolUser' do
      before do
        allow(SchoolMember).to receive(:find_by_school_and_user).and_return school_member
      end
      it 'should build a SchoolUser' do
        expect(controller.find_or_initialize_school_user).to be(school_member)
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