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
        expect(subject).to eq '01/01/2020'
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
end
