require_relative '../../transforms/sum_values'

describe SumValues do
  let(:subject) { SumValues.new(output_column, *input_columns) }
  let(:input_columns) { [:foo, :bar, :baz] }
  let(:output_column) { :qux }

  describe '#process' do
    context 'with columns passed as arguments' do
      let(:row) { { foo: 1, bar: 2, baz: 3} }
      it 'should sum the values in each column' do
        output = subject.process(row)
        expect(output).to eq({ foo: 1, bar: 2, baz: 3, qux: 6 })
      end
    end

    context 'when given nil and other values' do
      let(:row) { { foo: 1, bar: nil, baz: 5 } }
      it 'should return the sum of the values aside from nil' do
       output = subject.process(row)
       expect(output).to eq({ foo: 1, bar: nil, baz: 5, qux: 6 })
      end
    end

    context 'when given only nil values' do
      let(:row) { { foo: nil, bar: nil, baz: nil } }
      it 'should return nil' do
        output = subject.process(row)
        expect(output).to eq({foo: nil, bar: nil, baz: nil, qux: nil})
      end
    end
  end
end
