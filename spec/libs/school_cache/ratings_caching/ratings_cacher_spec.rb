require 'spec_helper'

describe RatingsCaching::GsdataRatingsCacher do

  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { RatingsCaching::GsdataRatingsCacher.new(school) }

  describe '#cache' do
    after(:each) { clean_models :gsdata, DataValue, Source, DataType }
    let(:source) { build(:source).tap { |obj| obj.on_db(:gsdata_rw).save } }
    let(:school_value) { (1..100).to_a.sample }
    let(:data_type_id) { RatingsCaching::GsdataRatingsCacher::DATA_TYPE_IDS.sample }
    let(:data_type) { create_data_type(id: data_type_id) }
    let!(:data_values) do
      create_data_values(
        data_type_id: data_type.id,
        value: school_value,
        school_id: school.id,
        source_id: source.id
      )
    end

    let(:cache_row) do
      SchoolCache.where("school_id = ? and state = ?", school.id,school.state)
    end
    let(:metadata) do
      SchoolMetadata.on_db(:ca).where(school_id: school.id, meta_key: 'overallRating')
    end

    context 'when a school has actual ratings data' do
      before { cacher.cache }

      it 'should insert ratings for the school' do
        expect(cache_row).to_not be_empty
        expect(cache_row.size).to eq(1)
        ratings = JSON.parse(cache_row[0].value)
        expect(ratings.size).to eq(1)
        expect(ratings[data_type.name]).to be_present
        expect(ratings[data_type.name][0]['school_value']).to eq(school_value.to_s)
      end
    end

    context 'when rating value is missing' do
      let!(:data_values) do
        create_data_values(
          data_type_id: data_type.id,
          school_id: school.id,
          source_id: source.id,
          value: ''
        )
      end
      before { cacher.cache }
      subject { cache_row }

      it { is_expected.to be_empty }
    end

    context 'when source name is missing' do
      let(:source) do
        build(:source, source_name: '').tap { |obj| obj.on_db(:gsdata_rw).save }
      end
      before { cacher.cache }
      subject { cache_row }
      it { is_expected.to be_empty }
    end

    context 'when a school has a GS Rating' do
      let(:data_type_id) { 160 }
      let!(:data_type) { create_data_type(id: data_type_id, name: 'Summary Rating') }
      let!(:data_values) do
        create_data_values(
          data_type_id: data_type.id,
          value: school_value,
          school_id: school.id,
          source_id: source.id
        )
      end

      subject { cacher.cache }

      it 'should insert school_metadata' do
        subject
        expect(metadata).to be_present
      end

      it 'handles a race condition in school_metadata by trying again' do
        metadata_class = double('SchoolMetadata')
        metadata = double('SchoolMetadata')
        expect(SchoolMetadata).to receive(:on_db).exactly(4).times.and_return metadata_class
        expect(metadata_class).to receive(:find_by).and_return nil
        expect(metadata_class).to receive(:create).and_raise(ActiveRecord::RecordNotUnique, 'foo')
        expect(metadata_class).to receive(:find_by).and_return metadata
        subject
      end

      it 'will not endlessly loop on school_metadata race conditions' do
        metadata_class = double('SchoolMetadata')
        expect(SchoolMetadata).to receive(:on_db).exactly(4).times.and_return metadata_class
        expect(metadata_class).to receive(:find_by).and_return nil
        expect(metadata_class).to receive(:create).and_raise(ActiveRecord::RecordNotUnique, 'foo')
        expect(metadata_class).to receive(:find_by).and_return nil
        expect(metadata_class).to receive(:create).and_raise(ActiveRecord::RecordNotUnique, 'foo')
        expect { subject }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    context 'when a school does not have data values' do
      let!(:data_values) { nil }
      before { cacher.cache }
      subject { cache_row }
      it { is_expected.to be_empty }
    end
  end

  describe '#build_hash_for_cache' do
    subject { cacher.build_hash_for_cache }
    before do
      allow(cacher).to receive(:state_results_hash).and_return({})
      allow(cacher).to receive(:district_results_hash).and_return({})
    end

    [1,2,3].each do |data_type_id|
      context "with data for data type #{data_type_id}" do
        let(:school_value) { rand }
        before do
          allow(cacher).to receive(:school_results).and_return(
            [
              json_data_value(data_type_id: data_type_id, value: school_value, source_name: 'Foo')
            ]
          )
        end
        it "sets the right school value" do
          results = subject["Rating #{data_type_id}"]
          results.each do |r|
            expect(r[:school_value]).to eq(school_value)
          end
        end
        it "should not add description and methodology to data type #{data_type_id}" do
          results = subject["Rating #{data_type_id}"]
          expect(results).to be_present
          results.each do |r|
            expect(r).to_not have_key(:description)
            expect(r).to_not have_key(:methodology)
          end
        end
      end
    end

    [155, 156, 158, 159, 183, 184].each do |data_type_id|
      context "with data for data type #{data_type_id}" do
        before do
          allow(cacher).to receive(:school_results).and_return(
            [
              json_data_value(data_type_id: data_type_id, value: 10, source_name: 'Foo')
            ]
          )
        end
        it "adds description and methodology to data type #{data_type_id}" do
        end
      end
    end

    context "with data for several data types that include tags" do
      before do
        allow(cacher).to receive(:school_results).and_return(
          [
            json_data_value(data_type_id: 151, value: 10, source_name: 'Foo', breakdown_tags: ['foo']),
            json_data_value(data_type_id: 152, value: 10, source_name: 'Foo', breakdown_tags: ['bar']),
            json_data_value(data_type_id: 153, value: 10, source_name: 'Foo', breakdown_tags: ['baz'])
          ]
        )
      end

      it 'should keep only course_subject_groups for advanced coursework rating' do
        results = subject["Rating 151"]
        expect(results).to be_empty
      end

      it 'should not remove valid values just because they have tags' do
        [152,153].each do |data_type_id|
          results = subject["Rating #{data_type_id}"]
          expect(results).to be_present
          results.each do |r|
            expect(r).to have_key(:breakdown_tags)
            expect(r[:breakdown_tags]).to_not be_empty
          end
        end
      end
    end
  end


  def create_data_values(props)
    props.reverse_merge!(
      breakdowns: [nil],
      breakdown_tags: [],
      date_valid: Time.now
    )
    props[:breakdowns].map do |breakdown|
      build(
        :data_value,
        props.slice(:value, :state, :school_id, :district_id, :data_type_id, :source_id, :configuration, :active, :created, :updated)
      ).on_db(:gsdata_rw).save
    end
  end

  def json_data_value(hash)
    props = {
      data_type_id: nil,
      name: "Rating #{hash[:data_type_id]}",
      breakdowns: nil,
      breakdown_tags: nil,
      date_valid: Time.now,
      value: nil,
      district_value: nil,
      display_range: nil,
      source_name: nil,
      school_id: nil
    }
    OpenStruct.new(props.merge(hash))
  end

  def create_data_type(args)
    args = args.reject { |_,v| v.nil? }
    build(:data_type, args).tap { |obj| obj.on_db(:gsdata_rw).save }
  end
end

