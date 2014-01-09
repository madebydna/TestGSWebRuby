require 'spec_helper'

describe Subscription do

  it 'should belong to a User' do
    association = Subscription.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end

  describe '.subscription_product' do
    it 'should work give the same result whether you provide symbol or string' do
      expect(Subscription.subscription_product(:mystat)).to eq(Subscription.subscription_product('mystat'))
    end

    it 'should have an entry for mystat' do
      expect(Subscription.subscription_product :mystat).to_not be_nil
    end
  end

end
