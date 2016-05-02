require_relative '../../transforms/catch_duplicates'
require_relative '../../row'

describe CatchDuplicates do
  subject { described_class.new *columns_selected }
  let(:columns_selected) { [:foo, :bar] }
  let(:dup_data) { rows[1].select { |k, v| columns_selected.include? k} }
  let(:dup_message) { "Duplicate data: #{dup_data.inspect} for rows [0, 1]" }
  let(:rows) { hashes.each_with_index.map { |h, i| GS::ETL::Row.new h, i } }
  let(:processed_rows) { rows.each { |row| subject.process(row) } }

  context 'when raising on first duplicate' do
    describe '#process' do
      context 'when passed a row that is not a duplicate' do
        let(:hashes) { [{foo:1, baz:2, bar:3}, {foo:4, baz:5, bar:6}] }
        it { expect{processed_rows}.to_not raise_error }
      end

      context 'when passed a row that is a duplicate' do
        let(:hashes) { [{foo:1, bar:2, baz:3}, {foo:1, bar:2, baz:3}] }
        it { expect{processed_rows}.to raise_error dup_message }
      end
    end
  end

  context 'when accumulating duplicates' do
    subject { described_class.new(true, *columns_selected) }

    describe '#process' do
      context 'when passed a row that is a duplicate' do
        let(:hashes) { [{foo:1, bar:2, baz:3}, {foo:1, bar:2, baz:3}] }

        it 'should print duplicates' do
          allow(subject).to receive(:puts)
          processed_rows
          expect(subject).to have_received(:puts).with(dup_message)
        end
      end
    end
  end
end
