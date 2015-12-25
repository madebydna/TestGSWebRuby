require 'spec_helper'

describe FlashMessageConcerns do
  let(:controller) { FakeController.new }
  let(:message) { 'sample message'}
  before(:all) do
    class FakeController
      include  FlashMessageConcerns
    end
  end

  subject { controller }
  after(:all) { Object.send :remove_const, :FakeController }

  describe '#flash_message' do
    let(:flash_hash) { {notice:[]} }
    before { allow(subject).to receive(:flash).and_return(flash_hash) }

    it 'should set a flash message' do
      subject.send :flash_message, :notice, 'message'
      expect(subject.flash[:notice]).to eq ['message']
    end

    it 'should append to existing messages' do
      subject.send :flash_message, :notice, 'first message'
      expect(subject.flash[:notice]).to eq ['first message']

      subject.send :flash_message, :notice, 'second message'
      expect(subject.flash[:notice]).to eq ['first message', 'second message']
    end

    it 'should set an array of messages' do
      subject.send :flash_message, :notice, ['first message', 'second message']
      expect(subject.flash[:notice]).to eq ['first message', 'second message']
    end
  end

  describe '#flash_error' do
    it 'should set a flash message with error' do
      expect(subject).to receive(:flash_message).with(:error, message)
      subject.send :flash_error, message
    end
  end

  describe '#flash_success' do
    it 'should set a flash message with success' do
      expect(subject).to receive(:flash_message).with(:success, message)
      subject.send :flash_success, message
    end
  end

  describe '#flash_notice' do
    it 'should set a flash message with success' do
      expect(subject).to receive(:flash_message).with(:notice, message)
      subject.send :flash_notice, message
    end
  end

  describe '#flash_notice_include?' do
    it 'should check if flash notices includes message' do
      test_array = []
      allow(subject).to receive(:flash).and_return({notice: test_array})
      expect(test_array).to receive(:include?).with(message)
      subject.send :flash_notice_include?, message
    end
  end

end

