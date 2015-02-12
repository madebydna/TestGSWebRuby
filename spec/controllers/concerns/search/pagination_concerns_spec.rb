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
      allow(controller).to receive(:results_offset)
      allow(controller).to receive(:page_size)
      allow(controller).to receive(:page_number)
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
        pending('PT-1213: TODO: fix code or rspec')
        ### Seems to only fail when running all the specs
        ### stack level too deep error
        fail
        expect(controller.instance_variable_defined?(var)).to be_falsey
        controller.send(:set_pagination_instance_variables, nil)
        expect(controller.instance_variable_defined?(var)).to be_truthy
      end
    end
  end

  describe '#page_number' do
    it 'should return the value of page_parameter when page_parameter is greater than 1' do
      [2, 5, 10].each do | p_num |
        allow(controller).to receive(:page_parameter).and_return(p_num)
        expect(controller.send(:page_number)).to eql(p_num)
      end
    end
    it 'should return 1 when the page_parameter is 1 or less, nil, or a string' do
      [1, -1, -10, nil, 'not_a_number'].each do | p_num |
        allow(controller).to receive(:page_parameter).and_return(p_num)
        expect(controller.send(:page_number)).to eql(1)
      end
    end
  end

  describe '#results_offset' do
    let(:page_size) { controller.send(:page_size) }
    it 'should return 0 if the page number is 1 or less' do
      [1, 0, -1, -10].each do | p_num |
        allow(controller).to receive(:page_parameter).and_return(p_num)
        expect(controller.send(:results_offset)).to eql(0)
      end
    end
    it 'should return the (page number - 1) * the page size if page number is greater than 1' do
      [2, 5, 10].each do | p_num |
        allow(controller).to receive(:page_parameter).and_return(p_num)
        expect(controller.send(:results_offset)).to eql((p_num-1) * page_size)
      end
    end
  end

  describe '#calc_max_number_of_pages' do
    let(:page_size) { controller.send(:page_size) }
    it 'should return 1 when total results is less than or equal to page size' do
      [0, -1, 10 % page_size, 20 % page_size ].each do | num_of_results |
        expect(controller.send(:calc_max_number_of_pages, num_of_results)).to eql(1)
      end
    end
    it 'should return total results / page size when it divides equally' do
      [page_size * 2, page_size * 3, page_size * 4].each do | num_of_results |
        expect(controller.send(:calc_max_number_of_pages, num_of_results)).to eql(num_of_results / page_size)
      end
    end
    it 'should return total results / page size + 1 when there is a remainder' do
      [page_size * 2 + 1, page_size * 3 + 1, page_size * 4 + 1].each do | num_of_results |
        expect(controller.send(:calc_max_number_of_pages, num_of_results)).to eql(num_of_results / page_size + 1)
      end
    end
  end
end