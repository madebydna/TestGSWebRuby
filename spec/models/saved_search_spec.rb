require 'spec_helper'

describe SavedSearch do
  it { is_expected.to be_a(SavedSearch) }

  describe '.searches_named' do
    subject { SavedSearch.searches_named(name).to_sql }

    describe 'normal name' do
      let(:name) { 'foo' }

      it { is_expected.to include("name = 'foo'") }
      it { is_expected.to include("name like 'foo%(%)'") }
    end

    describe 'SQL injection name' do
      let(:name) { "qwe'OR 9338=IF('1'='2',9338,SLEEP(1)) AND '1'='1" }

      it { is_expected.to include("name = 'qwe\\'OR 9338=IF(\\'1\\'=\\'2\\',9338,SLEEP(1)) AND \\'1\\'=\\'1'") }
      it { is_expected.to include("name like 'qwe\\'OR 9338=IF(\\'1\\'=\\'2\\',9338,SLEEP(1)) AND \\'1\\'=\\'1%(%)'") }

      it 'is expected to be valid SQL' do
        expect(SavedSearch.searches_named(name).count).to eq(0)
      end
    end
  end
end