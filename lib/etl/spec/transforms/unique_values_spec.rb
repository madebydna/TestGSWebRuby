require_relative '../../transforms/unique_values'

describe UniqueValues do
  let(:subject) { UniqueValues.new(*fields) }
  let(:fields) { [:ca_label, :gs_label] }

  describe '#initialize' do
    context 'when given nil' do
      it 'should raise an error' do
        expect{ subject(nil) }.to raise_error
      end
    end
  end

  describe '#process' do
    context 'with source columns' do
      let(:row) { {ca_label: 'ca_id', gs_label: 'gs_id', foo: 'bar'} }

      it 'should delete values that are not specified fields in initialize' do
        subject.process(row)
        expect(row).to have_key(:ca_label)
        expect(row).to_not have_key(:foo)
      end

      it 'should return nil' do
        expect(subject.process(row)).to be_nil
      end
    end
  end
end
