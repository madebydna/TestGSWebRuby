require 'spec_helper'
shared_examples 'a loader' do |loader_class|

  let(:empty_loader) { loader_class.new(nil, nil, nil) }

  [:load!, :insert_into!, :disable!].each do |method|
    it "should have a #{method} method" do
      expect(empty_loader).to respond_to(method)
    end
  end

end