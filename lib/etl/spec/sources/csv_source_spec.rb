require_relative '../../sources/csv_source'

describe CsvSource do
  let(:files) { double('files') }
  let(:options) { Hash.new }
  let(:csv_source) { CsvSource.new(files, options) }
  subject { csv_source }

  describe '#initialize' do
    describe 'when given nil' do
      let(:files) { nil }
      it 'is expected to raise an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    describe 'when given an empty array' do
      let(:files) { Array.new }
      it 'is expected to raise an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    describe 'when given a single file' do
      it { is_expected.to be_a(CsvSource) }
    end

    describe 'when given an empty options hash' do
      it 'should set default options' do
       expect(csv_source.instance_variable_get(:@options)).to eq(CsvSource::DEFAULT_OPTIONS)
      end
    end
  end

  describe '#each' do
    context 'when given two files' do
      let(:files) { [double('file1'), double('file2')] }
      let(:fake_csv) { double('csv', open: csv_instance) }
      let(:csv_instance) do
        double('csv', each_with_index: proc do |row, num|
          yield(row, 1)
        end)
      end
      let(:row) do
        {
          foo: 123,
          bar: 456
        }
      end
      subject { csv_source.each }
      before do
        pending
        fail
        stub_const('CSV', fake_csv)
      end
      it 'calls CSV.foreach on each file' do
        subject
        expect(csv_instance).to have_received(:each_with_index).with(files[0], csv_source.instance_variable_get(:@options))
        expect(csv_instance).to have_received(:each_with_index).with(files[1], csv_source.instance_variable_get(:@options))
      end

    end
  end

end
