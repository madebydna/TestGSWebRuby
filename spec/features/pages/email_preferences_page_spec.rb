require 'spec_helper'
require 'features/contexts/shared_contexts_for_signed_in_users'
require 'features/page_objects/email_preferences_page'

describe 'Email preferences page', js: true do
  subject { EmailPreferencesPage.new }
  include_context 'signed in verified user'

  after do
    clean_dbs :gs_schooldb
  end

  context 'with no existing subscriptions' do
    before do
      subject.load
    end
    let(:new_sub) { user.subscriptions.last }

    context 'English newsletters' do
      it 'can subscribe to the weekly newsletter' do
        subject.english.weekly.click
        subject.submit_btn.click
        expect(new_sub.list).to eq('greatnews')
        expect(subject.subscribed?(subject.english.weekly)).to be true
      end

      it 'can subscribe to a selection of grade newsletters' do
        subject.english.grades.fifth_grade.click
        subject.english.grades.kg.click
        subject.submit_btn.click

        # DB confirmation
        grade_subs = user.student_grade_levels.map {|l| [l.grade, l.language]}
        expect(grade_subs).to contain_exactly(['KG', 'en'], ['5', 'en'])

        # visual confirmation
        expect(subject.subscribed?(subject.english.grade_by_grade)).to be true
        expect(subject.subscribed?(subject.english.grades.kg)).to be true
        expect(subject.subscribed?(subject.english.grades.fifth_grade)).to be true
      end

      it 'can subscribe to the teacher newsletter' do
        subject.english.educators.click
        subject.submit_btn.click
        expect(new_sub.list).to eq('teacher_list')
        expect(subject.subscribed?(subject.english.educators)).to be true
      end

      it 'can subscribe to the partner updates newsletter' do
        subject.english.sponsor.click
        subject.submit_btn.click
        expect(new_sub.list).to eq('sponsor')
        expect(subject.subscribed?(subject.english.sponsor)).to be true
      end
    end

    context 'Spanish newsletters' do
      before do
        subject.spanish_tab.click
      end

      it 'can subscribe to the weekly newsletter' do
        subject.spanish.weekly.click
        subject.submit_btn.click
        # for now, we need to click Spanish tab again
        subject.spanish_tab.click
        expect(new_sub.list).to eq('greatnews')
        expect(new_sub.language).to eq('es')
        expect(subject.subscribed?(subject.spanish.weekly)).to be true
      end

      it 'can subscribe to a selection of grade newsletters' do
        subject.spanish.grades.second_grade.click
        subject.spanish.grades.ninth_grade.click
        subject.submit_btn.click
        subject.spanish_tab.click

        # DB confirmation
        grade_subs = user.student_grade_levels.map {|l| [l.grade, l.language]}
        expect(grade_subs).to contain_exactly(['2', 'es'], ['9', 'es'])

        # visual confirmation
        expect(subject.subscribed?(subject.spanish.grade_by_grade)).to be true
        expect(subject.subscribed?(subject.spanish.grades.second_grade)).to be true
        expect(subject.subscribed?(subject.spanish.grades.ninth_grade)).to be true
      end
    end
  end

  context 'with existing subscriptions' do
    context 'to English newsletters' do
      before do
        user.subscriptions.create(list: 'greatnews', language: 'en')
        user.student_grade_levels.create(grade: 3, language: 'en')
        subject.load
      end

      it 'shows existing subscriptions' do
        expect(subject.subscribed?(subject.english.weekly)).to be true
        expect(subject.subscribed?(subject.english.grade_by_grade)).to be true
        expect(subject.subscribed?(subject.english.grades.third_grade)).to be true
      end

      it 'allows user to unsubscribe from specific subscription' do
        subject.english.weekly.click
        subject.submit_btn.click
        current_subs = user.subscriptions.reload.map(&:list)
        expect(current_subs).not_to include('greatnews')
        expect(subject.subscribed?(subject.english.weekly)).to be false
      end
    end

    context 'to Spanish newsletters' do
      before do
        user.subscriptions.create(list: 'greatnews', language: 'es')
        user.student_grade_levels.create(grade: 6, language: 'es')
        user.student_grade_levels.create(grade: 8, language: 'es')
        subject.load
        subject.spanish_tab.click
      end

      it 'shows existing subscriptions' do
        expect(subject.subscribed?(subject.spanish.weekly)).to be true
        expect(subject.subscribed?(subject.spanish.grade_by_grade)).to be true
        expect(subject.subscribed?(subject.spanish.grades.sixth_grade)).to be true
        expect(subject.subscribed?(subject.spanish.grades.eighth_grade)).to be true
      end

      it 'allows user to unsubscribe from specific subscription' do
        subject.spanish.weekly.click
        subject.spanish.grades.sixth_grade.click
        subject.submit_btn.click

        current_subs = user.subscriptions.reload.map(&:list)
        current_grades = user.student_grade_levels.reload.map(&:grade)
        expect(current_subs).not_to include('greatnews')
        expect(current_grades).not_to include('6')

        subject.spanish_tab.click
        expect(subject.subscribed?(subject.spanish.weekly)).to be false
        expect(subject.subscribed?(subject.spanish.grades.sixth_grade)).to be false
      end
    end
  end

  context 'with school subscriptions' do
    after { clean_dbs :ca }
    let(:school) { create(:school) }
    let(:school_sub) { subject.school_updates.get_subscription(school) }
    before do
      user.subscriptions.create(list: 'mystat', state: school.state, school_id: school.id)
      subject.load
    end

    it 'should have School Updates section' do
      expect(subject).to have_school_updates
    end

    it 'should have active subscription to school newsletter' do
      expect(school_sub).to be_truthy
    end

    it 'should allow unsubscribing from school' do
      school_sub.click
      subject.submit_btn.click

      current_subs = user.subscriptions.reload.map(&:list)
      expect(current_subs).not_to include('mystat')

      expect(subject).not_to have_school_updates
    end

  end

  context 'with district-level grade subscriptions' do
    let(:district) { create(:district_record) }
    let(:english_district) { subject.english.district_grades.get_district(district) }
    let(:spanish_district) { subject.spanish.district_grades.get_district(district) }
    before do
      user.student_grade_levels.create(
        grade: 6,
        language: 'en',
        district_id: district.district_id,
        district_state: district.state
      )

      user.student_grade_levels.create(
        grade: 5,
        language: 'es',
        district_id: district.district_id,
        district_state: district.state
      )
      subject.load
    end

    it 'should have English district grade-by-grade section' do
      expect(english_district).to be_truthy
      expect(english_district.subscribed?).to be true
    end

    it 'should have Spanish district grade-by-grade section' do
      subject.spanish_tab.click
      expect(spanish_district).to be_truthy
      expect(spanish_district.subscribed?).to be true
    end

    it 'should be subscribed to English district grade newsletter' do
      district_grade = english_district.grades.sixth_grade
      expect(district_grade[:class]).to include("active")
    end


    it 'should be subscribed to Spanish district grade newsletter' do
      subject.spanish_tab.click
      district_grade = spanish_district.grades.fifth_grade
      expect(district_grade[:class]).to include("active")
    end

    it 'should allow unsubscribing from English district grade' do
      district_grade = english_district.grades.sixth_grade
      district_grade.click
      subject.submit_btn.click

      # DB confirmation
      grade_subs = user.student_grade_levels.map {|l| [l.district_id, l.district_state, l.language]}
      expect(grade_subs).not_to include([district.id, district.state, 'en'])

      # visual confirmation
      english_district = subject.english.district_grades.get_district(district)
      expect(english_district.subscribed?).to be false
    end

    it 'should allow unsubscribing from Spanish district grade' do
      subject.spanish_tab.click
      district_grade = spanish_district.grades.fifth_grade
      district_grade.click
      subject.submit_btn.click

      # DB confirmation
      grade_subs = user.student_grade_levels.map {|l| [l.district_id, l.district_state, l.language]}
      expect(grade_subs).not_to include([district.id, district.state, 'es'])

      # visual confirmation
      subject.spanish_tab.click
      spanish_district = subject.spanish.district_grades.get_district(district)
      expect(spanish_district.subscribed?).to be false
    end
  end

end