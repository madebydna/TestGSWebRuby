require 'spec_helper'

describe DisplayRange do
  describe '#for' do
    [
      ['census', 1, nil, 'ca', nil,  100,  'census', 1, nil, nil,  nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, nil, 'ca', nil,  100,  'census', 1, nil, 'de', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['census', 1, nil, 'ca', 2010, 100,  'census', 1, nil, nil,  2010, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, nil, 'ca', nil,  100,  'census', 1, nil, 'ca', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, nil, 'ca', 2010, 100,  'census', 1, nil, 'ca', 2010, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, nil, 'ca', 2015, 100,  'census', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, nil, 'ca', 2015, 45,   'census', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'average'],
      ['census', 1, nil, 'ca', 2015, 25,   'census', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'below_average'],
      ['census', 1, nil, 'ca', 2015, 30.5, 'census', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'average'],
      ['census', 1, nil, 'ca', 2015, 25,   'census', 1, nil, 'ca', 2015, {'above_average_cap'=>101,'below_average_cap'=>30,'average_cap'=>60}.to_json, 'below_average'],
      ['census', 1, nil, 'ca', 2015, 25,   'census', 1, nil, 'ca', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'below_average'],
      ['census', 1, nil, 'ca', 2015, 59.5,   'census', 1, nil, 'ca', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'average'],
      ['census', 1, nil, 'ca', 2015, 60.3,   'census', 1, nil, 'ca', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'average'],
      ['census', 1, nil, 'ca', 2015, 30.5, 'census', 1, nil, 'ca', 2014, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['census', 1, nil, 'ca', nil,  25,   'census', 1, nil, 'ca', 2015, {'above_average_cap'=>101,'below_average_cap'=>30,'average_cap'=>60}.to_json, nil],


      ['test', 1, nil, 'ca', nil,  100,  'census', 1, nil, nil,  nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', nil,  100,  'census', 1, nil, 'de', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', 2010, 100,  'census', 1, nil, nil,  2010, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', nil,  100,  'census', 1, nil, 'ca', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', 2010, 100,  'census', 1, nil, 'ca', 2010, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', 2015, 100,  'census', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', 2015, 45,   'census', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', 2015, 25,   'census', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', 2015, 30.5, 'census', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', 2015, 25,   'census', 1, nil, 'ca', 2015, {'above_average_cap'=>101,'below_average_cap'=>30,'average_cap'=>60}.to_json, nil],
      ['test', 1, nil, 'ca', 2015, 25,   'census', 1, nil, 'ca', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', 2015, 30.5, 'census', 1, nil, 'ca', 2014, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, nil, 'ca', nil,  25,   'census', 1, nil, 'ca', 2015, {'above_average_cap'=>101,'below_average_cap'=>30,'average_cap'=>60}.to_json, nil],


      ['test', 1, 1, 'ca', 2015, 25,   'test', 1, nil, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'below_average'],
      ['test', 1, 1, 'ca', 2015, 25,   'test', 1, 1, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'below_average'],
      ['test', 1, nil, 'ca', 2015, 25,   'test', 1, 1, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['test', 1, 1, 'ca', 2015, 25,   'test', 1, 1, 'ca', nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'below_average'],
      ['test', 1, 1, 'ca', 2015, 25,   'test', 1, 1, nil, 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'below_average'],
      ['test', 1, 1, 'ca', 2015, 25,   'test', 1, 1, nil, nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'below_average'],
      # We round before calculating the bucket so these two should get the same.
      # This is because we display rounded values and so we don't want to have,
      # for example, two 60's with different colors.
      ['test', 1, 1, 'ca', 2015, 59.5,   'test', 1, 1, nil, nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'average'],
      ['test', 1, 1, 'ca', 2015, 60.3,   'test', 1, 1, nil, nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'average'],
    ].each do | data_type, data_type_id, subject_id, state, year, school_value, range_data_type, range_data_type_id, range_subject_id, range_state, range_year, range, return_value |

      context "when passing in {data_type: #{data_type}, data_type_id: #{data_type_id}, subject_id: #{subject_id || 'nil'}, state: #{state}, year: #{year || 'nil'}, value: #{school_value}}" do
        context "when the range: #{range} is available for data_type= #{range_data_type} data_type_id=#{range_data_type_id} subject_id=#{range_subject_id || 'all'} state=#{range_state || 'all'} year=#{range_year || 'all'}" do
          let(:display_ranges) do
            { [range_data_type, range_data_type_id, (range_subject_id || 'all'), (range_state || 'all'), (range_year || 'all')] => [
              FactoryGirl.build(:display_range, data_type: range_data_type, data_type_id: range_data_type_id, subject_id: range_subject_id, state: range_state, year: range_year)
            ] }
          end
          before { allow(DisplayRange).to receive(:grouped_display_ranges).and_return(display_ranges) }

          it "should return #{return_value || 'nil'}" do
            v = DisplayRange.for({
              data_type:    data_type,
              data_type_id: data_type_id,
              subject_id:   subject_id,
              state:        state,
              year:         year,
              value:        school_value
            })
            expect(v).to eql(return_value)
          end
        end
      end
    end
  end

  describe '#cached_ranges' do
    it 'should cache display_ranges_map' do
      expect(DisplayRange).to receive(:display_ranges_map).once
      5.times do
        DisplayRange.cached_ranges
      end
    end
  end

  describe '#grouped_display_ranges' do
    context 'with several display_ranges in the database' do

      before do
        [
          [ 1, nil, nil,  2009, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json],
          [ 2, nil, 'de', nil,  {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json],
          [ 3, nil, 'ca', 2011, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json],
          [ 3, nil, 'ca', 2012, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json],
          [ 4, nil, 'ca', (Time.now.year + 1), {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json]
        ].each do | data_type_id, subject_id, state, year, ranges |
          FactoryGirl.create(:display_range, data_type_id: data_type_id, subject_id: subject_id, state: state, year: year, ranges: ranges)
        end
      end
  
      after { clean_models :gs_schooldb, DisplayRange }
  
      it 'should group them by data_type/data_type_id/subject_id/state/year key' do
        dr = DisplayRange.where(data_type_id: 3).first
        dr_map = DisplayRange.grouped_display_ranges
        dr_in_map = dr_map[['census', dr.data_type_id, 'all', dr.state, dr.year]].first
        expect(dr).to eql(dr_in_map)
      end

      it 'should group them by data_type/data_type_id/subject_id/all key if there is no state' do
        dr = DisplayRange.where(data_type_id: 1).first
        dr_map = DisplayRange.grouped_display_ranges
        dr_in_map = dr_map[['census', dr.data_type_id, 'all',  'all', dr.year]].first
        expect(dr).to eql(dr_in_map)
      end

      it 'should not return ranges that have years in the future' do
        dr_map = DisplayRange.grouped_display_ranges
        dr_in_map = dr_map[['census', 4, 'all', 'ca', (Time.now.year + 1)]]
        expect(dr_in_map).to eql(nil)
      end

    end
  end

end
