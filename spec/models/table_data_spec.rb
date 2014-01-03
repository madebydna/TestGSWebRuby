require 'spec_helper'

describe TableData do

  describe '#sort!' do

    describe 'sorting on one column' do
      let(:data) {[
          { id: 1, name: 'c', score: 3 },
          { id: 2, name: 'a', score: 2 },
          { id: 3, name: 'b', score: 1 }
      ]}

      subject(:table_data) { TableData.new data }

      it 'should sort in ascending order on one column' do
        table_data.sort!(key: 'name', direction: 'ascending')
        expect(table_data.rows.map{|row| row[:id] }).to eq [2, 3, 1]
      end

      it 'should sort in descending order on one column' do
        table_data.sort!(key: 'name', direction: 'descending')
        expect(table_data.rows.map{|row| row[:id] }).to eq [1, 3, 2]
      end

      it 'should sort in ascending order by default' do
        table_data.sort!(key: 'name')
        expect(table_data.rows.map{|row| row[:id] }).to eq [2, 3, 1]
      end
    end

    describe 'sorting on multiple columns' do
      let(:data) {[
          { id: 1, name: 'b', score: 4 },
          { id: 2, name: 'a', score: 2 },
          { id: 3, name: 'a', score: 1 },
          { id: 4, name: 'b', score: 3 }
      ]}

      subject(:table_data) { TableData.new data }

      it 'should sort in ascending order on two columns' do
        table_data.sort!([
            {
              key: 'name',
              direction: 'ascending'
            },
            {
              key: 'score',
              direction: 'ascending'
            }
        ])
        expect(table_data.rows.map{|row| row[:id] }).to eq [3, 2, 4, 1]
      end

      it 'should sort in different directions on different columns' do
        table_data.sort!([
            {
                key: 'name',
                direction: 'ascending'
            },
            {
                key: 'score',
                direction: 'descending'
            }
        ])
        expect(table_data.rows.map{|row| row[:id] }).to eq [2, 3, 1, 4]

        table_data.sort!([
            {
                key: 'name',
                direction: 'descending'
            },
            {
                key: 'score',
                direction: 'ascending'
            }
        ])
        expect(table_data.rows.map{|row| row[:id] }).to eq [4, 1, 3, 2]
      end
    end

    describe 'should handle nulls' do
      let(:data) {[
        { id: 1, name: nil, score: 3 },
        { id: 2, name: 'b', score: nil },
        { id: 3, name: nil, score: nil }
      ]}

      subject(:table_data) { TableData.new data }

      it 'should sort in ascending order on one column' do
        table_data.sort!(key: 'name', direction: 'ascending')
        expect(table_data.rows.map{|row| row[:id] }).to eq [2, 1, 3]
      end

      it 'should sort in descending order on one column' do
        table_data.sort!(key: 'name', direction: 'descending')
        expect(table_data.rows.map{|row| row[:id] }).to eq [2, 1, 3]
      end

    end

  end

end