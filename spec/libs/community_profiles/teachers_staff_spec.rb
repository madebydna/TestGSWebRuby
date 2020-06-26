require 'spec_helper'

describe CommunityProfiles::TeachersStaff do
  after { do_clean_dbs(:gs_schooldb) }
  let!(:district) { create(:district_record) }
  let(:cache_reader) {
    DistrictCacheDataReader.new(district, district_cache_keys: ['metrics'])
  }

  before do
    @current_cache = create_metrics_cache(build(:teacher_staff_cache))
  end

  subject(:ts) { CommunityProfiles::TeachersStaff.new(cache_reader) }

  describe "#data_values" do
    let(:data) { ts.data_values }

    it "is a hash" do
      expect(data).to be_a(Hash)
    end

    it "has a state key with the state of the district" do
      expect(data[:state]).to eq(district.state)
    end

    it "has district_id key with the district's id" do
      expect(data[:district_id]).to eq(district.district_id)
    end
  end


  describe "#main_staff_data" do
    let(:data) { ts.main_staff_data }

    it "is an array of hashes" do
      expect(data).to be_a(Array)
      expect(data).to all( be_a(Hash) )
    end

    it "has hashes with expected keys" do
      first_item = data.first
      expect(first_item).to have_key(:name)
      expect(first_item).to have_key(:tooltip)
      expect(first_item).to have_key(:type)
      expect(first_item).to have_key(:district_value)
      expect(first_item).to have_key(:state_value)
      expect(first_item).to have_key(:year)
      expect(first_item).to have_key(:source)
    end

    it "ignores missing keys in the cache" do
      all_data_types = ts.main_staff_data_types # array of expected hash keys
      # build hash with the last data type missing
      data_with_missing_key = all_data_types[0..-2].reduce({}) do |memo, key|
        memo[key] = [ build(:main_staff_hash) ]
        memo
      end
      allow(cache_reader.decorated_district).to receive(:metrics).and_return(data_with_missing_key)
      # should be missing translated 'Ratio of teacher salary to total number of teachers'
      t = data.detect {|h| h[:name] == translate_key(all_data_types.last.to_sym) }
      expect(t).to be_nil
    end

    it "ignores missing values in the cache" do
      data_with_missing_value= {
        'Ratio of students to full time teachers' => [ build(:main_staff_hash) ],
        'Percentage of full time teachers who are certified' => [ ]
      }
      allow(cache_reader.decorated_district).to receive(:metrics).and_return(data_with_missing_value)
      t = data.detect {|h| h[:name] == translate_key('Percentage of full time teachers who are certified') }
      expect(t).to be_nil
    end

    it "returns an empty array when there is no staff data in the cache" do
      allow(ts).to receive(:main_staff_hash).and_return({})
      expect(data).to be_empty
    end

    it "select latest year data for each data type" do
      data_with_multiple_years = {
        'Ratio of students to full time teachers' => [
          build(:main_staff_hash, source_date_valid: "20160101 00:00:00"),
          build(:main_staff_hash, source_date_valid: "20140101 00:00:00")]
      }
      allow(cache_reader.decorated_district).to receive(:metrics).and_return(data_with_multiple_years)
      translated_key = translate_key('Ratio of students to full time teachers')
      matches = data.select {|h| h[:name] == translated_key }
      expect(matches.length).to eq(1)
      expect(matches.first[:year]).to eq(2016)
    end
  end

  describe "#other_staff_data" do
    let(:data) { ts.other_staff_data }
    it "has a data key that is an array of hashes" do
      expect(data).to be_a(Array)
      expect(data).to all( be_a(Hash) )
    end

    it "has hashes with expected keys" do
      first_item = data.first
      expect(first_item).to have_key(:name)
      expect(first_item).to have_key(:tooltip)
      expect(first_item).to have_key(:type)
      expect(first_item).to have_key(:full_time_district_value)
      expect(first_item).to have_key(:full_time_state_value)
      expect(first_item).to have_key(:part_time_district_value)
      expect(first_item).to have_key(:part_time_state_value)
      expect(first_item).to have_key(:year)
      expect(first_item).to have_key(:source)
    end

    it "ignores missing keys in the cache" do
      all_data_types = ts.other_staff_data_types # array of expected hash keys
      # build hash with all but one of the possible
      data_with_missing_key = all_data_types[0..-2].reduce({}) do |memo, key|
        memo[key] = [
          build(:full_time_other_staff),
          build(:part_time_other_staff),
          build(:no_other_staff) ]
        memo
      end
      allow(cache_reader.decorated_district).to receive(:metrics).and_return(data_with_missing_key)
      # should be missing translated 'Percent of Security Guard Staff'
      t = data.detect {|h| h[:name] == translate_key(all_data_types.last) }
      expect(t).to be_nil
    end

    it "ignores missing values in the cache" do
      data_with_missing_value= {
        'Percent of Nurse Staff' => [
          build(:full_time_other_staff),
          build(:part_time_other_staff),
          build(:no_other_staff)],
        'Percentage of Psychologist Staff' => [ ]
      }
      allow(cache_reader.decorated_district).to receive(:metrics).and_return(data_with_missing_value)
      t = data.detect {|h| h[:name] == translate_key('Percentage of Psychologist Staff') }
      expect(t).to be_nil
    end

    it "returns an empty array when there is no staff data in the cache" do
      allow(ts).to receive(:other_staff_hash).and_return({})
      expect(data).to be_empty
    end

    it "selects latest year for each data type" do
      data_with_multiple_years = {
        'Percent of Psychologist Staff' => [
          build(:full_time_other_staff, source_date_valid: "2016-01-01 00:00:00"),
          build(:full_time_other_staff, source_date_valid: "2014-01-01 00:00:00"),
          build(:part_time_other_staff, source_date_valid: "2016-01-01 00:00:00"),
          build(:part_time_other_staff, source_date_valid: "2014-01-01 00:00:00"),
          build(:no_other_staff, source_date_valid: "2016-01-01 00:00:00"),
          build(:no_other_staff, source_date_valid: "2014-01-01 00:00:00") ]
      }
      allow(cache_reader.decorated_district).to receive(:metrics).and_return(data_with_multiple_years)
      matches = data.select {|h| h[:name] == translate_key('Percent of Psychologist Staff') }
      expect(matches.length).to eq(1)
      expect(matches.first[:year]).to eq(2016)
    end
  end

  describe "#sources_data" do
    let(:data) { ts.sources_data }

    it "is an array of hashes" do
      expect(data).to be_a(Array)
      expect(data).to all( be_a(Hash) )
    end

    it "has hashes with expected keys" do
      first_item = data.first
      expect(first_item).to have_key(:name)
      expect(first_item).to have_key(:description)
      expect(first_item).to have_key(:source_and_year)
    end

    it "is built from main and other staff data" do
      example_data = {
        'Percent of Nurse Staff' => [
          build(:full_time_other_staff,
            source: "ABC Data Collection",
            source_date_valid: "20170101 00:00:00"),
          build(:part_time_other_staff),
          build(:no_other_staff)],
        'Ratio of students to full time teachers' => [
          build(:main_staff_hash, source: "CRDC",
            source_date_valid: "20180101 00:00:00")
        ]
      }

      allow(cache_reader.decorated_district).to receive(:metrics).and_return(example_data)

      expected_source_data = [
        {
          name: translate_key('Ratio of students to full time teachers'),
          description: translate_key('Ratio of students to full time teachers', scope: 'lib.teachers_staff.data_point_info_texts.district'),
          source_and_year: "CRDC, 2018"
        },
        {
          name: translate_key('Percent of Nurse Staff'),
          description: translate_key('Percent of Nurse Staff', scope: 'lib.teachers_staff.data_point_info_texts.district'),
          source_and_year: "ABC Data Collection, 2017"

        }
      ]
      expect(data).to eq(expected_source_data)
    end
  end

  def create_metrics_cache(value)
    create(:district_cache, district_id: district.district_id, state: district.state.upcase,
      name: "metrics", value: value.to_json)
  end

  def translate_key(key, scope: 'lib.teachers_staff')
    I18n.t(key.to_sym, scope: scope)
  end

end