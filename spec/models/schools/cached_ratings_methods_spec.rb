require 'spec_helper'

describe CachedRatingsMethods do
  before(:all) do
    class FakeModel
      include CachedRatingsMethods
    end
  end
  after(:all) { Object.send :remove_const, :FakeModel }
  let(:model) { FakeModel.new }

  describe '#ratings_matching_criteria' do
    subject { model.ratings_matching_criteria(ratings, criteria) }
    let(:ratings) do
      [
        {
          a: 1,
          b: 2,
          c: 3
        },
        {
          a: 4,
          b: 5,
          c: 6
        }
      ]
    end

    context 'with nil criteria' do
      let(:criteria) do
        {
          b: 2,
          c: nil
        }
      end
      it { is_expected.to eq([{a: 1, b: 2, c: 3}]) }
    end

    context 'with multiple criteria' do
      let(:criteria) do
        {
          a: 4,
          c: 6
        }
      end
      it { is_expected.to eq([{a: 4, b: 5, c: 6}]) }
    end
  end

  describe '#ratings_having_max_year' do
    subject { model.ratings_having_max_year(ratings) }
    let(:ratings) do
      [
        {
          'year' => 2016,
        },
        {
          'year' => 2015,
        },
        {
          'year' => 2016,
        }
      ]
    end

    it 'should return objects matching latest year' do
      expect(subject - [ratings[0], ratings[2]]).to be_empty
    end
  end

  describe '#school_rating_hash_by_id' do
    subject { model.school_rating_hash_by_id(165) }
    before { allow(model).to receive(:ratings).and_return(ratings) }

    context 'with multiple breakdowns and multiple years' do
      let(:ratings) do
        [
          {
            'data_type_id' => 165,
            'school_value_float' => '1.0',
            'year' => 2016,
            'breakdown' => 'Asian'
          },
          {
            'data_type_id' => 165,
            'school_value_float' => '2.0',
            'year' => 2016,
            'breakdown' => 'All students'
          },
          {
            'data_type_id' => 165,
            'school_value_float' => '3.0',
            'year' => 2015,
            'breakdown' => 'All students'
          }
        ]
      end
      it 'returns hash for all students for most recent year' do
        expect(subject).to be_a(Hash)
        expect(subject['school_value_float']).to eq('2.0')
      end
    end
  end

  describe '#school_rating_all_hash_by_id' do
    subject { model.school_rating_all_hash_by_id(165) }
    before { allow(model).to receive(:ratings).and_return(ratings) }

    context 'with multiple breakdowns and multiple years' do
      let(:ratings) do
        [
          {
            'data_type_id' => 165,
            'school_value_float' => '4.0',
            'year' => 2014,
            'breakdown' => 'All students'
          },
          {
            'data_type_id' => 165,
            'school_value_float' => '1.0',
            'year' => 2016,
            'breakdown' => 'Asian'
          },
          {
            'data_type_id' => 165,
            'school_value_float' => '2.0',
            'year' => 2016,
            'breakdown' => 'All students'
          },
          {
            'data_type_id' => 165,
            'school_value_float' => '3.0',
            'year' => 2015,
            'breakdown' => 'All students'
          }
        ]
      end
      it 'returns hash for all breakdowns and most recent year' do
        expect(subject).to be_a(Array)
        expect(subject.map { |r| r['school_value_float'] }).to eq(['1.0','2.0'])
      end
    end
  end

  describe '#school_historical_rating_hashes_by_id' do
    subject { model.school_historical_rating_hashes_by_id(165) }
    before { allow(model).to receive(:ratings).and_return(ratings) }

    context 'with multiple breakdowns and multiple years' do
      let(:ratings) do
        [
          {
            'data_type_id' => 165,
            'school_value_float' => '4.0',
            'year' => 2014,
            'breakdown' => 'All students'
          },
          {
            'data_type_id' => 165,
            'school_value_float' => '1.0',
            'year' => 2016,
            'breakdown' => 'Asian'
          },
          {
            'data_type_id' => 165,
            'school_value_float' => '2.0',
            'year' => 2016,
            'breakdown' => 'All students'
          },
          {
            'data_type_id' => 165,
            'school_value_float' => '3.0',
            'year' => 2015,
            'breakdown' => 'Asian'
          }
        ]
      end

      it 'returns hash for all students breakdown and all years sorted desc' do
        expect(subject).to be_a(Array)
        expect(subject.map { |r| r['year'] }).to eq([2016,2014])
      end

      it 'returns school values to ints' do
        expect(subject.map { |r| r['school_value_float'] }).to eq([2,4])
      end
    end
  end

end
