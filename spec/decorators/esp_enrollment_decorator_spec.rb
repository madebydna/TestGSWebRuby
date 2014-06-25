require 'spec_helper'

describe EspEnrollmentDecorator do

  describe '#application_deadline' do

    subject do
      EspEnrollmentDecorator.new(esp_enrollment_data).application_deadline
    end

    context 'When application_deadline is "date"' do
      # MI 5874
      let(:esp_enrollment_data) do
        {
          'application_deadline' => 'date',
          'application_deadline_date' => '01/01/2020'
        }
      end

      it 'it should return the actual date' do
        expect(subject).to eq 'January 01, 2020'
      end
    end

    context 'When application_deadline is "date" and its not in the right format to parse' do
      let(:esp_enrollment_data) do
        {
          'application_deadline' => 'date',
          'application_deadline_date' => '28/01/2020'
        }
      end

      it 'should return the date string' do
        expect(subject).to eq '28/01/2020'
        end
      end

    context 'When application_deadline is "yearround"' do
      # MI 4667
      let(:esp_enrollment_data) do
        {
          'application_deadline' => 'yearround',
          'application_deadline_date' => '01/01/2020'
        }
      end

      it ' it should return "Rolling deadline"' do
        expect(subject).to eq 'Rolling deadline'
      end
    end

    context 'When application_deadline is "parents_contact"' do
      # MI 9043
      let(:esp_enrollment_data) do
        {
          'application_deadline' => 'parents_contact',
          'application_deadline_date' => '01/01/2020'
        }
      end

      it ' it should return "Contact school"' do
        expect(subject).to eq 'Contact school'
      end
    end

    context 'When application_deadline is something else' do
      let(:esp_enrollment_data) do
        {
          'application_deadline' => 'blah',
          'application_deadline_date' => '01/01/2020'
        }
      end

      it 'it should return nil' do
        expect(subject).to be_nil
      end
    end

    context 'When application_deadline is not present' do
      let(:esp_enrollment_data) do
        {
          'blah' => 'blah'
        }
      end

      it 'it should return nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#enrollment_chances' do
    subject do
      EspEnrollmentDecorator.new(esp_enrollment_data).enrollment_chances
    end

    context 'When enrollment_chances has the same date for applications received and students accepted' do
      # MI 5874
      let(:esp_enrollment_data) do
        {
          'applications_received_year' => '2013-2014',
          'students_accepted_year' => '2013-2014',
          'students_accepted'  => '900',
          'applications_received'  => '900'
        }
      end

      it 'it should return a number' do
        expect(subject).to eq '10'
      end
    end

    context 'When enrollment_chances has the accepted students half the size of applications received' do
      # MI 5874
      let(:esp_enrollment_data) do
        {
          'applications_received_year' => '2013-2014',
          'students_accepted_year' => '2013-2014',
          'students_accepted'  => '450',
          'applications_received'  => '900'
        }
      end

      it 'it should return 5' do
        expect(subject).to eq '5'
      end
    end
    context 'When enrollment_chances has the different dates' do
      # MI 5874
      let(:esp_enrollment_data) do
        {
          'applications_received_year' => '2013-2014',
          'students_accepted_year' => '2013',
          'students_accepted'  => '450',
          'applications_received'  => '900'
        }
      end

      it 'it should return "no info"' do
        expect(subject).to eq 'no info'
      end
    end
    context 'When enrollment_chances has 0 applications received' do
      # MI 5874
      let(:esp_enrollment_data) do
        {
          'applications_received_year' => '2013-2014',
          'students_accepted_year' => '2013-2014',
          'students_accepted'  => '450',
          'applications_received'  => '0'
        }
      end

      it 'it should return "no info"' do
        expect(subject).to eq 'no info'
      end
    end
    context 'When enrollment_chances has nil applications received' do
      # MI 5874
      let(:esp_enrollment_data) do
        {
          'applications_received_year' => '2013-2014',
          'students_accepted_year' => '2013-2014',
          'students_accepted'  => nil,
          'applications_received'  => nil
        }
      end

      it 'it should return "no info"' do
        expect(subject).to eq 'no info'
      end
    end
  end
end
