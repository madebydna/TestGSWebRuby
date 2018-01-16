require 'spec_helper'

describe DistrictsMetaTagsConcerns do

  subject do
    o = Object.new
    o.singleton_class.instance_eval { include DistrictsMetaTagsConcerns }
    o
  end

  context 'with a state, city, and district instance vars set' do
    before do
      subject.instance_variable_set(:@state, {:short => 'ca'})
      subject.instance_variable_set(:@city, 'oakland')
      subject.instance_variable_set(:@district, FactoryGirl.build(:oakland_unified))
    end

    it 'should return the correct title string' do
      expect(subject.send(:districts_show_title)).to eql("Oakland Unified School District in Oakland, CA | GreatSchools")
    end
  end

end