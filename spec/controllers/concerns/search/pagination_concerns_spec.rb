require 'spec_helper'

describe PaginationConcerns do

  before(:all) do
    class FakeController < ApplicationController
      include PaginationConcerns
    end
  end
  after(:all) { Object.send :remove_const, :FakeController }
  let(:controller) { FakeController.new }

  describe '#set_page_instance_variables' do
    before do
      controller.stub(:results_offset)
      controller.stub(:page_size)
      controller.stub(:page_number)
    end
    [:@results_offset, :@page_size, :@page_number].each do |var|
      it "should set #{var.to_s} instance variable" do
        expect(controller.instance_variable_defined?(var)).to be_falsey
        controller.send(:set_page_instance_variables)
        expect(controller.instance_variable_defined?(var)).to be_truthy
      end
    end
  end
  describe '#set_pagination_instance_variables' do
    before do
      allow(controller).to receive(:calc_kaminari_window_size)
      allow(controller).to receive(:calc_max_number_of_pages)
      allow(controller).to receive(:page_size)
      allow(controller).to receive(:page_number)
      allow_any_instance_of(NilClass).to receive(:page)
      allow_any_instance_of(NilClass).to receive(:per)
      allow(Kaminari).to receive(:paginate_array)
      allow_message_expectations_on_nil
    end
    [:@max_number_of_pages, :@window_size, :@pagination].each do |var|
      it "should set #{var.to_s} instance variable" do
        expect(controller.instance_variable_defined?(var)).to be_falsey
        controller.send(:set_pagination_instance_variables, nil)
        expect(controller.instance_variable_defined?(var)).to be_truthy
      end
    end
  end
end