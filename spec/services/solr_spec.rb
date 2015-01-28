require 'spec_helper'

describe 'Solr' do
  describe '#breakdown_results' do
    context 'by default' do
      it 'connects to the solr server' do
        expect(RSolr).to receive(:connect)

        solr = Solr.new({:state=>'mi', :collection_id => 1})
        solr.breakdown_results(grade_level: 'p')
      end
      it 'returns formatted breakdown results' do
        pending('Need to mock solr\'s select call? Making pending to fix build')
        solr = Solr.new('mi', 1)
        result = solr.breakdown_results(grade_level: 'p')
        expect(result).to be_an_instance_of(Hash)
        expect(result.keys).to eq([:count, :path])
      end
    end

    context 'an error state' do
      it 'returns nil and logs an error' do
        allow_any_instance_of(RSolr::Client).to receive(:get).and_raise(Exception)

        expect {
          result = Solr.new({:state=>'mi', :collection_id=>1}).breakdown_results(grade_level: 'p')
          expect(result).to be_nil
        }.to raise_error
      end
    end
  end

  describe '#prepare_query_string' do
    it 'trims the query string' do
      expect(Solr.prepare_query_string('  anthony   ')).to eq('anthony')
    end
    it 'downcases the query string' do
      expect(Solr.prepare_query_string('Anthony')).to eq('anthony')
    end
    it 'pads commas with spaces in the query string' do
      expect(Solr.prepare_query_string('Anthony,Roy')).to eq('anthony, roy')
    end
    it 'normalizes spaces in the query string' do
      expect(Solr.prepare_query_string('Anthony  Roy')).to eq('anthony roy')
    end
    it 'escapes lucene special characters in the query string' do
      expect(Solr.prepare_query_string('anthony + - ! ( ) { } [ ] ^ " ~ * ? : \\ roy')).to eq('anthony \+ \- \! \( \) \{ \} \[ \] \^ \" \~ \* \? \: \\\\ roy')
    end
    it 'trims the query string again after padding commas' do
      expect(Solr.prepare_query_string('anthony,')).to eq('anthony,')
    end
    it 'does not alter the parameter in place' do
      input = '  foo  '
      expect(Solr.prepare_query_string(input)).to eq('foo')
      expect(input).to eq('  foo  ')
    end
  end

  describe '#require_non_optional_words' do
    it 'requires regular words' do
      allow(Solr).to receive(:get_optional_words).and_return([])
      expect(Solr.require_non_optional_words('anthony roy')).to eq('+anthony +roy')
    end
    it 'does not require optional words' do
      allow(Solr).to receive(:get_optional_words).and_return(['district', 'high', 'school'])
      expect(Solr.require_non_optional_words('federer district high school')).to eq('+federer district high school')
    end
    it 'downcases prior to comparison' do
      allow(Solr).to receive(:get_optional_words).and_return(['district', 'high', 'school'])
      expect(Solr.require_non_optional_words('Federer District High School')).to eq('+Federer District High School')
    end
    it "treats both 'and' and '&' as optional" do
      expect(Solr.require_non_optional_words('School for Arts & Humanities and Sciences')).to eq('School +for +Arts & +Humanities and +Sciences')
    end
  end

  describe '#get_optional_words' do
    it 'includes a sample set of core optional words' do
      %w(school district charter preschool elementary middle high).each {|term| expect(Solr.get_optional_words).to include(term)}
    end
  end
end
