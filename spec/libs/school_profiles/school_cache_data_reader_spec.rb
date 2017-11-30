require 'spec_helper'

describe SchoolProfiles::SchoolCacheDataReader do
  def new_reader(school, *args)
    SchoolProfiles::SchoolCacheDataReader.new(school, *args)
  end

  context 'when given a school' do
    let(:school) do
      double('school').tap do |s|
        allow(s).to receive(:state).and_return('ca')
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

    describe '#characteristics_data' do
      let(:reader) { new_reader(school) }
      subject { reader.characteristics_data(:foo, :bar) }
      context 'with missing sources' do
        before do
          allow(reader).to receive(:decorated_school).and_return(
            OpenStruct.new(
              characteristics: {
                foo: [
                  {
                    'source' => 'abc',
                    'label' => 'foo label'
                  },
                  {
                    'label' => 'foo label'
                  }
                ],
                bar: [
                  {
                    'label' => 'foo label'
                  },
                  {
                    'source' => 'abc',
                    'label' => 'foo label'
                  }
                ]
              }
            )
          )
        end
        it 'should reject the hashes that have missing source' do
          expect(subject.values.flatten.select { |h| !h.has_key?('source') }).to be_empty
          expect(subject.values.flatten.select { |h| h.has_key?('source') }.size).to eq(2)
        end
      end
    end


  end

  context 'when not given a school' do
    describe '.new' do 
      subject { SchoolProfiles::SchoolCacheDataReader }
      it 'should raise an error' do
        expect { subject.new(nil) }.to raise_error
      end
    end
  end

end

