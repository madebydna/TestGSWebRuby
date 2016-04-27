require_relative '../gs_school_ids_fetcher'

describe GsSchoolIdsFetcher do
  let(:values_array) { [5] }
  let(:column) { [{state_id: 4}] }
  let(:fake_column_fetcher_class) { double() }
  before do
     fetcher = double(values_array: values_array, column: column)
     stub_const('ShardedDatabaseColumnFetcher', fake_column_fetcher_class)
     allow(fake_column_fetcher_class).to receive(:new).and_return(fetcher)
  end
  let(:subject) { gs_school_ids_fetcher = GsSchoolIdsFetcher.new('dev.greatschools.org','ca') }
  describe '#column' do
    it 'should instantiate column fetcher with correct params' do
      expect(fake_column_fetcher_class).to receive(:new).with('dev.greatschools.org', 'ca', 'school', 'state_id', 'where state_id != \'\'')
      subject.column
    end
    it 'should return column' do
      expect(subject.column).to eq(column)
    end
  end
  describe '#values_array' do
    it 'should return values array' do
      expect(subject.values_array).to eq(values_array)
    end
  end
end
