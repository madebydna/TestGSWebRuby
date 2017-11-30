require "spec_helper"

describe SchoolProfiles::NearbySchools do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:nearby_schools) do
    SchoolProfiles::NearbySchools.new(
        school_cache_data_reader: school_cache_data_reader
    )
  end
  it { is_expected.to respond_to(:closest_top_then_top_nearby_schools) }

  describe '#closest_top_then_top_nearby_schools' do
    let(:sample_data) do
      {
          'closest_top_then_top_nearby_schools' => [
              {
                  name: 'My School',
                  id: 1
              }, {
                  name: 'Your School',
                  id: 2
              }

          ],
          'closest_schools' => [
              {
                  name: 'Bad School #1',
                  id: 3
              }, {
                  name: 'Bad School #2',
                  id: 4
              }
          ]
      }
    end

    subject { nearby_schools.closest_top_then_top_nearby_schools }

    it 'should return chosen data types if data present' do
      expect(school_cache_data_reader).to receive(:nearby_schools).and_return(sample_data)

      expect(subject.size).to eq(2)
      expect(subject[0][:id]).to eq(1)
      expect(subject[1][:id]).to eq(2)
    end

    it 'should return empty array if no methodology' do
      expect(school_cache_data_reader).to receive(:nearby_schools).
          and_return(sample_data.except('closest_top_then_top_nearby_schools'))
      expect(subject).not_to be_nil
      expect(subject).to be_empty
    end

    it 'should return empty array if no data' do
      expect(school_cache_data_reader).to receive(:nearby_schools).and_return(nil)
      expect(subject).not_to be_nil
      expect(subject).to be_empty
    end
  end
end
