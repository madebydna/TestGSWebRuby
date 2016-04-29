require_relative '../../transforms/catch_duplicates'

describe CatchDuplicates do
  let(:subject) { CatchDuplicates.new(*columns_selected)}
  let(:columns_selected) { [:foo, :bar] }

  describe '#key_for_row' do
    context 'when passed a row' do
      let(:row) { {foo:1, bar:2, baz:3} }
      it 'should select the values determined by columns_selected' do
        expect(subject.key_for_row(row)).to eq [1, 2]
      end
    end
  end

  describe '#process' do
    let(:processed_rows) { rows.each { |row| subject.process(row) } }
    context 'when passed a row that is not a duplicate' do
      let(:rows) { [{foo:1, bar:2, baz:3}, {foo:4, bar:5, baz:6}] }
      it { expect{processed_rows}.to_not raise_error }
    end

    context 'when passed a row that is a duplicate' do
      let(:rows) { [{foo:1, bar:2, baz:3}, {foo:1, bar:2, baz:3}] }
      let(:dup_message) { rows[1].select { |k, v| columns_selected.include? k}.inspect }
      it { expect{processed_rows}.to raise_error("Duplicate data: #{dup_message}")}
    end
  end
end