require 'spec_helper'

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
      let(:event_log) { double('event log', process: nil) }
      let(:files) { [double('file1'), double('file2')] }
      let(:fake_csv) do
        double('csv', foreach: proc do |file|
          yield(row)
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
        stub_const('CSV', fake_csv)
      end
      it 'calls CSV.foreach on each file' do
        subject
        expect(fake_csv).to have_received(:foreach).with(files[0], csv_source.instance_variable_get(:@options))
        expect(fake_csv).to have_received(:foreach).with(files[1], csv_source.instance_variable_get(:@options))
      end

    end
  end

end
