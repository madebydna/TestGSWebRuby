require 'spec_helper'

describe Advertising do
  subject do
    Advertising.new
  end

  describe '@ad_slots' do
    it 'should contain only hashes' do
      ad_slots = subject.instance_variable_get(:@ad_slots)
      expect(ad_slots).not_to be_nil
      ad_slots.each do |k,v|
        expect(v.class).to eq(Hash), "@ad_slots[:#{k}] is not a Hash"
      end
    end
  end
end