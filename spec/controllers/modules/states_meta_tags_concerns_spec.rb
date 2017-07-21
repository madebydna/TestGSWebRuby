require 'spec_helper'

describe StatesMetaTagsConcerns do

  subject do
    o = Object.new
    o.singleton_class.instance_eval { include StatesMetaTagsConcerns }
    o
  end

  describe '#states_show_title' do
    context 'with a state instance var set' do
      before { subject.instance_variable_set(:@state, {:short => 'ca', :long => 'california'}) }
      it 'should return the correct title string' do
        expect(subject.send(:states_show_title)).to eql("California Schools - California State School Ratings - Public and Private")
      end
    end


    context 'where state is Pennsylvania' do
      before { subject.instance_variable_set(:@state, {:short => 'pa', :long => 'pennsylvania'}) }
      it 'should return the correct title string' do
        expect(subject.send(:states_show_title)).to eql("Pennsylvania State 2017 School Ratings | Public & Private")
      end
    end
  end

end
