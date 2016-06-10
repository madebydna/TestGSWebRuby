require 'spec_helper'

describe CitiesMetaTagsConcerns do

  subject do
    o = Object.new
    o.singleton_class.instance_eval { include CitiesMetaTagsConcerns }
    o
  end

  context 'with a city instance var set' do
    city = 'Oakland'
    before { subject.instance_variable_set(:@city, city) }

    [ # method                  asserted_text
      ['cities_programs_title',       "#{city} programs"],
      ['cities_programs_keywords',    "#{city} programs, child care"],
      ['cities_programs_description', "Resources and providers of programs in #{city}"],
    ].each do | (method, asserted_text) |
      it "should return '#{asserted_text}'" do
        expect(subject.send(method)).to eql(asserted_text)
      end
    end
  end
end
