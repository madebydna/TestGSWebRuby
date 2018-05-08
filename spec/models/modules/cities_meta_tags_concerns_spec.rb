require 'spec_helper'

describe CitiesMetaTagsConcerns do

  subject do
    o = Object.new
    o.singleton_class.instance_eval { include CitiesMetaTagsConcerns }
    o
  end

  context 'with a city instance var set' do
    city = 'Oakland'
    state = {long: 'California', short: 'ca' }
    before do
      subject.instance_variable_set(:@city, city)
      subject.instance_variable_set(:@state, state)
    end

    [ # method                  asserted_text
      ['cities_programs_title',       "#{city} programs"],
      ['cities_show_title',   "Best Schools in #{city}, CA | School Ratings in #{city}, California"],
      ['cities_programs_description', "Resources and providers of programs in #{city}"],
    ].each do | (method, asserted_text) |
      it "should return '#{asserted_text}'" do
        expect(subject.send(method)).to eql(asserted_text)
      end
    end
  end
end
