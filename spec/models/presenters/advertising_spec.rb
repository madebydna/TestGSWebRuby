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
        expect(v).to be_a(Hash), "@ad_slots[:#{k}] is not a Hash"
      end
    end
  end

  describe '#get_dimensions' do
    it 'should return dimentions for valid input' do
      result = subject.get_dimensions(:School_Overview, :Text, :Mobile)
      #puts result
      expect(result).to be_present
      expect(result.first.size).to eq(2)
    end
  end

  describe '#get_height' do
    context 'when ad slot supports multiple sizes' do
      let(:ad_page) { :School_Overview }
      let(:ad_slot) { :Text }
      let(:browser_size) { :Mobile }
      it 'will return only the height of the first size' do
        result = subject.get_height(ad_page, ad_slot, browser_size)
        expect(result).to eq(60)
      end
    end
  end

end