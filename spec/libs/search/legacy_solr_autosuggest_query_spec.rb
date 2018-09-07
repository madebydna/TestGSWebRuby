# frozen_string_literal: true

describe Search::LegacySolrAutosuggestQuery do
  let(:q) { nil }

  subject { Search::LegacySolrAutosuggestQuery.new(q) }

  {
    '' => nil,
    '94612' => '94612',
    '9461' => '9461',
    '946' => '946',
    '94' => nil,
    '9' => nil,
    'oakland 94612' => '94612',
    'oakland 946' => '946', 
    'oakland 94' => nil, 
    '123 94612' => '94612',
    '946120 school' => nil,
    '94612,ca' => '94612',
    '946,ca' => '946',
  }.each do |q, possible_zip|
    context "when query is #{q || 'nil'}" do
      let(:q) { q }
      it "#possible_zip should return #{possible_zip || 'nil'}" do
        expect(subject.possible_zip).to eq(possible_zip)
      end
    end
  end

end