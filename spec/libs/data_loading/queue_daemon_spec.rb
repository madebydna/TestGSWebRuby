require 'spec_helper'

describe QueueDaemon do

  it 'should have the method to run the infinite loop' do
    expect(subject).to respond_to(:run!)
  end

  it 'should have the method to process unprocessed updates' do
    expect(subject).to respond_to(:process_unprocessed_updates)
  end
end