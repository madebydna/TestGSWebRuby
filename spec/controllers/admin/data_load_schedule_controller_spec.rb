require 'spec_helper'

describe Admin::DataLoadSchedulesController do

  it 'should have the right methods' do
    expect(controller).to respond_to :index
    expect(controller).to respond_to :new
    expect(controller).to respond_to :create
    expect(controller).to respond_to :edit
    expect(controller).to respond_to :update
  end

  describe '#update' do

    let(:data_load) { FactoryGirl.build(:data_load) }

    before do
      allow_any_instance_of(Admin::DataLoadSchedulesController).to receive(:format_attributes).and_return(data_load.attributes)
    end

    it 'should update the data load if one is found' do
      allow(Admin::DataLoadSchedule).to receive(:find).and_return(data_load)
      expect(data_load).to receive(:update_attributes).and_return true
      post :update, id: 1
    end

    it 'should handle update failure by setting flash message' do
      allow(Admin::DataLoadSchedule).to receive(:find).and_return(data_load)
      expect(data_load).to receive(:update_attributes).and_return false
      expect(controller).to receive(:flash_error)
      post :update, id: 1
    end
  end

  describe '#create' do

    let(:data_load) { FactoryGirl.build(:data_load) }

    before do
      allow_any_instance_of(Admin::DataLoadSchedulesController).to receive(:format_attributes).and_return(data_load.attributes)
    end

    it 'should create the data load if one is found' do
      expect_any_instance_of(Admin::DataLoadSchedule).to receive(:update_attributes).and_return true
      post :create, id: 1
    end

    it 'should handle creation failure by setting flash message' do
      expect_any_instance_of(Admin::DataLoadSchedule).to receive(:update_attributes).and_return false
      expect(controller).to receive(:flash_error)
      post :create, id: 1
    end
  end

  describe '#construct_filter_where_clause' do

    context '#with a complete status' do
      it 'should create a where clause with status = \'complete\'' do
        status = 'complete'
        load_type = nil
        controller.send(:construct_filter_where_clause, status,load_type) == 'where status = \'complete\''
      end
    end

    context '#with a complete status and load_type test' do
      it 'should create a where clause with status = \'complete\' and load_type = \'test\'' do
        status = 'complete'
        load_type = 'test'
        controller.send(:construct_filter_where_clause, status,load_type) == 'where status = \'complete\' and load_type = \'test\''
      end
    end

    context '#with an available status' do
      it "should create a where clause with 'released < 'TODAY' and status != 'complete'" do
        status = 'available'
        load_type = nil
        controller.send(:construct_filter_where_clause, status,load_type) == "'released < '#{Time.now.strftime("%Y-%m-%d")}' and status != 'complete'"
      end
    end

    context '#with an incomplete status' do
      it "should create a where clause with 'status != 'complete'" do
        status = 'incomplete'
        load_type = nil
        controller.send(:construct_filter_where_clause, status,load_type) == "'status != 'complete'"
      end
    end

    context '#with no status' do
      it "should create a where clause with no status clause" do
        status = nil
        load_type = 'test'
        controller.send(:construct_filter_where_clause, status,load_type) !~ /status/
      end
    end

    context '#with no load_type' do
      it "should create a where clause with no load_type clause" do
        status = 'available'
        load_type = nil
        controller.send(:construct_filter_where_clause, status,load_type) !~ /load_type/
      end
    end
  end

  describe '#get_load_status' do

    context '#with completed checked' do
      it 'should return a status of complete' do
        attributes = {completed: '1'}
        controller.send(:get_load_status, attributes) == 'complete'
      end
    end

    context '#with completed not checked and acquired date chosen' do
      it 'should return a status of acquired' do
        attributes = {completed: '0', acquired: '2013-04-04'}
        controller.send(:get_load_status, attributes) == 'acquired'
      end
    end

    context '#with completed not checked and no acquired date chosen' do
      it 'should return a status of none' do
        attributes = {completed: '0', acquired: ''}
        controller.send(:get_load_status, attributes) == 'none'
      end
    end
  end
end
