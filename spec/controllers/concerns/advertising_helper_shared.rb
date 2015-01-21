require 'spec_helper'

shared_examples_for 'a controller that sets the gon.set_ad_targeting hash' do |ad_targeting_hash|
  ad_targeting_hash.each do |key, value|
    it "should set the '#{key}' key with the value '#{value}' in gon" do
      ad_targeting = page.evaluate_script('gon.ad_set_targeting')
      expect(ad_targeting[key]).to eq(value)
    end
    it "should truncate the '#{value}' value to max 10 characters" do
      ad_targeting = page.evaluate_script('gon.ad_set_targeting')
      expect(ad_targeting[key].length).to be <= 10
    end
  end
end
