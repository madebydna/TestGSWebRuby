require 'spec_helper'

describe DisplayRange do
  describe '#for' do
    [
      ['census', 1, 'ca', 100, 1, nil, nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, 'ca', 100, 1, 'de', nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, nil],
      ['census', 1, 'ca', 100, 1, nil, 2010, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, 'ca', 100, 1, 'ca', nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, 'ca', 100, 1, 'ca', 2010, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, 'ca', 100, 1, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'above_average'],
      ['census', 1, 'ca', 45, 1, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'average'],
      ['census', 1, 'ca', 25, 1, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'below_average'],
      ['census', 1, 'ca', 30.5, 1, 'ca', 2015, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json, 'average'],
      ['census', 1, 'ca', 25, 1, 'ca', 2015, {'above_average_cap'=>101,'below_average_cap'=>30,'average_cap'=>60}.to_json, 'below_average'],
    ].each do | data_type, data_type_id, state, school_value, range_data_type_id, range_state, range_year, range, return_value |

      context "when passing in data_type=#{data_type} data_type_id=#{data_type_id} state=#{state} value=#{school_value}" do
        context "when the range: #{range} is available for data_type_id=#{range_data_type_id} state=#{state || 'all'} year=#{range_year || 'all'}" do
          let(:display_ranges) do
            { [data_type, range_data_type_id, (range_state || 'default')] => [
              FactoryGirl.build(:display_range, data_type_id: range_data_type_id, state: range_state, year: range_year)
            ] }
          end
          before { allow(DisplayRange).to receive(:display_ranges).and_return(display_ranges) }

          it "should return #{return_value || 'nil'}" do
            v = DisplayRange.for(data_type, data_type_id, state, school_value)
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

  describe '#display_ranges' do
    context 'with several display_ranges in the database' do

      before do
        [
          [ 1, nil, nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json],
          [ 2, 'de', nil, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json],
          [ 3, 'ca', 2011, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json],
          [ 3, 'ca', 2012, {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json],
          [ 4, 'ca', (Time.now.year + 1), {'below_average_cap'=>30,'average_cap'=>60,'above_average_cap'=>101}.to_json]
        ].each do | data_type_id, state, year, ranges |
          FactoryGirl.create(:display_range, data_type_id: data_type_id, state: state, year: year, ranges: ranges)
        end
      end
  
      after { clean_models :gs_schooldb, DisplayRange }
  
      it 'should group them by data_type/data_type_id/state key' do
        dr = DisplayRange.where(data_type_id: 2).first
        dr_map = DisplayRange.display_ranges
        dr_in_map = dr_map[['census', dr.data_type_id, dr.state]].first
        expect(dr).to eql(dr_in_map)
      end

      it 'should group them by data_type/data_type_id/default key if there is no state' do
        dr = DisplayRange.where(data_type_id: 1).first
        dr_map = DisplayRange.display_ranges
        dr_in_map = dr_map[['census', dr.data_type_id, 'default']].first
        expect(dr).to eql(dr_in_map)
      end

      it 'should order by year desc if grouping has multiple entries' do
        dr = DisplayRange.where(data_type_id: 3).order(year: :desc).to_a
        dr_map = DisplayRange.display_ranges
        dr_in_map = dr_map[['census', 3, 'ca']]
        expect(dr).to eql(dr_in_map)
      end

      it 'should not return ranges that have years in the future' do
        dr_map = DisplayRange.display_ranges
        dr_in_map = dr_map[['census', 4, 'ca']]
        expect(dr_in_map).to eql(nil)
      end

    end
  end

end
