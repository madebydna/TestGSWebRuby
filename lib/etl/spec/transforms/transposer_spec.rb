require_relative '../../transforms/transposer'

describe Transposer do

  describe '.new' do
    it 'should raise an error if label_field is not present' do
      expect { Transposer.new(nil, :foo, :bar) }.to raise_error(ArgumentError)
    end
    it 'should raise an error if value_field is not present' do
      expect { Transposer.new(:foo, nil, :bar) }.to raise_error(ArgumentError)
    end
    it 'should return a new instance when valid params are given' do
      expect(Transposer.new(:foo, :bar, :baz, :baz2)).to be_a(Transposer)
    end
  end

  describe '#process' do
    subject { Transposer.new(:type, :value, :public, :private, /gender/) }
    let(:row) do
      {
        public: 123,
        private: 456,
        gender_male: 78,
        gender_female: 90,
        gend_what: 100
      }
    end
    let(:result) { subject.process(row) }

    context 'when exploding two columns' do
      it 'should return four rows' do
        expect(result.size).to eq(4)
      end
      it 'each row should have the new label field' do
        result.each { |row| expect(row).to have_key(:type) }
      end
      it 'each row should have the new value field' do
        result.each { |row| expect(row).to have_key(:value) }
      end
      it 'the first exploded row should have "public" in the type field' do
        expect(result[0][:type]).to eq(:public)
      end
      it 'the second exploded row should have "private" in the type field' do
        expect(result[1][:type]).to eq(:private)
      end
      it 'the third exploded row should have "gender_male" in the type field' do
        expect(result[2][:type]).to eq(:gender_male)
      end
      it 'the fourth exploded row should have "gender_female" in the type field' do
        expect(result[3][:type]).to eq(:gender_female)
      end
      it 'the first exploded row should have "123" in the value field' do
        expect(result[0][:value]).to eq(123)
      end
      it 'the second exploded row should have "456" in the valuefield' do
        expect(result[1][:value]).to eq(456)
      end
      it 'the third exploded row should have "78" in the value field' do
        expect(result[2][:value]).to eq(78)
      end
      it 'the fourth exploded row should have "90" in the valuefield' do
        expect(result[3][:value]).to eq(90)
      end
    end

    it 'should record an event' do
      logger = double(log: nil)
      stub_const('GS::ETL::Logging', double(logger: logger))
      subject.instance_variable_set(:@logger, logger)
      subject.process(row)
      expect(logger).to have_received(:log)
    end

  end


end
