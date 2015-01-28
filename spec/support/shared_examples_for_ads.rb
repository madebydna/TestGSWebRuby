require 'spec_helper'

shared_examples_for 'page with ads' do |options|

  it "should have #{options[:number_of_ads]} ad slots" do
    expect(page).to have_selector('.gs_ad_slot', options[:number_of_ads] )
  end
end


