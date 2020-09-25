require 'spec_helper'

describe SchoolProfiles::SchoolCacheDataReader do
  def new_reader(school, *args)
    SchoolProfiles::SchoolCacheDataReader.new(school, *args)
  end

  before do
    @academic_progress_state_cache = FactoryBot.create(:state_cache, state: 'ca', name: 'state_attributes', value: "{\"growth_type\":\"Academic Progress Rating\"}")
    @student_progress_state_cache = FactoryBot.create(:state_cache, state: 'ar', name: 'state_attributes', value: "{\"growth_type\":\"Student Progress Rating\"}")
  end

  after do
    clean_dbs :gs_schooldb
  end

  context 'when given a school' do
    let(:school) do
      double('school').tap do |s|
        allow(s).to receive(:state).and_return('ca')
        allow(s).to receive(:id).and_return(1)
      end
    end
    let(:school2) do
      double('school').tap do |s|
        allow(s).to receive(:state).and_return('ar')
        allow(s).to receive(:id).and_return(1)
      end
    end
    subject { new_reader(school) }
    it { is_expected.to respond_to(:gs_rating) }
    it { is_expected.to respond_to(:nearby_schools) }

    describe '#school_cache_query' do
      before do
        allow(SchoolCacheQuery).to receive(:for_school).and_return(query)
      end
      let(:query) do
        double('query').tap do |q|
          allow(q).to receive(:include_cache_keys).and_return(q)
        end
      end
      let(:reader) { new_reader(school) }
      it 'makes a query using its school' do
        expect(SchoolCacheQuery).to receive(:for_school).with(school)
        reader.school_cache_query
      end

      context 'when given specific cache keys' do
        let(:keys) { %w[foo bar] }
        let(:reader) { new_reader(school, school_cache_keys: keys) }

        it 'tells the query to include the right cache keys' do
          expect(query).to receive(:include_cache_keys).with(keys)
          reader.school_cache_query
        end
      end
    end

    describe '#decorated_metrics_datas' do
      let(:reader) { new_reader(school) }
      subject { reader.decorated_metrics_datas(:foo, :bar) }
      before do
        allow(reader).to receive(:decorated_school).and_return(
          OpenStruct.new(
            decorated_metrics: {
              foo: [
                MetricsCaching::Value.from_hash({
                  'source' => 'abc',
                  'label' => 'foo label'
                }),
                MetricsCaching::Value.from_hash({
                  'label' => 'foo label'
                })
              ].extend(MetricsCaching::Value::CollectionMethods),
              bar: [
                MetricsCaching::Value.from_hash({
                  'label' => 'foo label'
                }),
                MetricsCaching::Value.from_hash({
                  'source' => 'abc',
                  'label' => 'foo label'
                })
              ].extend(MetricsCaching::Value::CollectionMethods)
            }
          )        )
      end

      it 'should include selected keys' do
        expect(subject).to include(:foo)
        expect(subject).to include(:bar)
      end
    end

    describe '#state_attributes' do
      context 'school is part of a academic progress rating state' do
        let(:reader) { new_reader(school) }
        it 'returns the right state attributes hash' do
          expect(reader.state_attributes).to eq({"growth_type" => "Academic Progress Rating"})
        end

        it 'has the right growth type' do
          expect(reader.growth_type).to eq("Academic Progress Rating")
        end
      end

      context 'school is part of a student progress rating state' do
        let(:reader) { new_reader(school2) }
        it 'returns the right state attributes hash' do
          expect(reader.state_attributes).to eq({"growth_type" => "Student Progress Rating"})
        end

        it 'has the right growth type' do
          expect(reader.growth_type).to eq("Student Progress Rating")
        end
      end
    end

  end

  context 'when not given a school' do
    describe '.new' do
      subject { SchoolProfiles::SchoolCacheDataReader }
      it 'should raise an error' do
        expect { subject.new(nil) }.to raise_error(ArgumentError)
      end
    end
  end

end

