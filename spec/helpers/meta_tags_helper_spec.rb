require 'spec_helper'

describe MetaTagsHelper do

  describe '#canonical_url_without_params' do

    let(:city_name) { 'Dover' }
    let(:state_name_long) { 'Delaware' }
    it 'should cut off trailing slash from url helper' do
      expect(helper.canonical_url_without_params(state_name_long, city_name)).to match /.*\w$/
    end
  end

end
