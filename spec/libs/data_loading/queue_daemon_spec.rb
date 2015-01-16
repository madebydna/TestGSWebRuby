require 'spec_helper'

describe QueueDaemon do
  queue_daemon_sleep_time    = ENV_GLOBAL['queue_daemon_sleep_time']
  queue_daemon_updates_limit = ENV_GLOBAL['queue_daemon_updates_limit'].to_i
  queue_daemon_updates_order = ENV_GLOBAL['queue_daemon_update_order']
  num_of_high_priority_items = queue_daemon_updates_limit / 2
  num_of_low_priority_items  = queue_daemon_updates_limit

  it 'should have the method to run the infinite loop' do
    expect(subject).to respond_to(:run!)
  end

  it 'should have the method to process unprocessed updates' do
    expect(subject).to respond_to(:process_unprocessed_updates)
  end

  describe '#get_updates' do
    high_priority_item = {source: :osp, status: :todo, priority: 2, update_blob: "{\"osp\":[{\"entity_state\":\"IN\",\"action\":\"build_cache\",\"entity_id\":\"3035\",\"entity_type\":\"school\"}]}"}
    low_priority_item  = {source: :osp, status: :todo, priority: 4, update_blob: "{\"osp\":[{\"entity_state\":\"IN\",\"action\":\"build_cache\",\"entity_id\":\"3035\",\"entity_type\":\"school\"}]}"}

    context "when there are #{num_of_high_priority_items} priority 2 and #{num_of_low_priority_items} priority 4 items in the update queue" do
      before(:all) do
        UpdateQueue.create(num_of_low_priority_items.times.map  { low_priority_item  })
        UpdateQueue.create(num_of_high_priority_items.times.map { high_priority_item })
      end

      after(:all) { clean_models UpdateQueue }
      it "should respond to #get_updates results" do
        expect(subject).to respond_to(:get_updates)
      end

      it "should return #{queue_daemon_updates_limit} results" do
        updates = subject.get_updates
        expect(updates.count).to eql queue_daemon_updates_limit
      end

      it "should return #{num_of_high_priority_items} priority 2 items and #{queue_daemon_updates_limit - num_of_high_priority_items} priority 4 items" do
        updates = subject.get_updates
        updates = updates.group_by { |update| update.priority }
        expect(updates[2].count).to eq num_of_high_priority_items
        expect(updates[4].count).to eq(queue_daemon_updates_limit - num_of_high_priority_items)
      end

      it "should return results ordered by time created" do
        updates = subject.get_updates
        updates = updates.group_by { |update| update.priority }

        high_priority_items = updates[2].sort_by { |update| update.created }
        expect(high_priority_items.first).to eq updates[2].first
        expect(high_priority_items.last).to eq updates[2].last

        low_priority_items = updates[4].sort_by { |update| update.created }
        expect(low_priority_items.first).to eq updates[4].first
        expect(low_priority_items.last).to eq updates[4].last
      end
    end
  end
  describe '#update_order' do
    it 'should return an array of integers' do
      order = subject.update_order

      expect(order).to be_an_instance_of Array
      order.each do |number|
        expect(number).to be_an_instance_of Fixnum
      end
    end
  end
end