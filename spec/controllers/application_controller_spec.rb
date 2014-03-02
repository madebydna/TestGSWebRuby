require 'spec_helper'
describe ApplicationController do


  it 'should have methods for manipulating cookies' do
    expect(controller).to respond_to(:write_cookie_value)
    expect(controller).to respond_to(:read_cookie_value)
    expect(controller).to respond_to(:delete_cookie)
  end

  describe '#write_cookie_value' do
    after do
      subject.class::COOKIE_CONFIG.delete :test_cookie
    end

    it 'should set a simple value' do
      subject.send :write_cookie_value, :test_cookie, 'value'
      expect(cookies['test_cookie']).to eq('value')
    end

    it 'should not overwrite cookie when asked not to' do
      subject.send :write_cookie_value, :test_cookie, 'value'
      subject.send :write_cookie_value, :test_cookie, 'new value should not overwrite', nil, false
      expect(cookies['test_cookie']).to eq 'value'
    end

    context 'when given options' do
      describe 'option "hash" is true' do
        it 'cookie key and value should be saved as json' do
          subject.send :write_cookie_value, :test_cookie, 'value', 'key', true, hash: true
          expect(cookies['test_cookie']).to eq({ key: 'value' }.to_json)
        end

        it 'should not save cookie as json if caller doesnt provide key' do
          subject.send :write_cookie_value, :test_cookie, 'value', nil, true, hash: true
          expect(cookies['test_cookie']).to eq 'value'.to_json
        end
      end

      describe 'option "hash" is false' do
        it 'should set cookie value as string and key is ignored' do
          subject.send :write_cookie_value, :test_cookie, 'value', 'key', true, hash: false
          expect(cookies['test_cookie']).to eq 'value'
        end
      end

      describe 'duration is set' do
        before do
          @cookie_jar = HashWithIndifferentAccess.new
          controller.stub(:cookies).and_return @cookie_jar
        end

        it 'should set duration on cookie' do
          test_duration = 1.day
          subject.send :write_cookie_value, :test_cookie, 'value', nil, true, duration: test_duration
          cookie = @cookie_jar[:test_cookie]
          expect(cookie[:expires].to_s).to eq test_duration.from_now.to_s
        end
      end
    end

    context 'when configured' do
      describe '"hash" is true' do
        before do
          subject.class::COOKIE_CONFIG[:test_cookie] = { hash: true }
        end
        it 'cookie key and value should be saved as json' do
          subject.send :write_cookie_value, :test_cookie, 'value', 'key', true
          expect(cookies['test_cookie']).to eq({ key: 'value' }.to_json)
        end

        it 'should not save cookie as json if caller doesnt provide key' do
          subject.send :write_cookie_value, :test_cookie, 'value', nil, true
          expect(cookies['test_cookie']).to eq 'value'.to_json
        end
      end

      describe '"hash" is false' do
        before do
          subject.class::COOKIE_CONFIG[:test_cookie] = { hash: false }
        end
        it 'should set cookie value as string and key is ignored' do
          subject.send :write_cookie_value, :test_cookie, 'value', 'key', true
          expect(cookies['test_cookie']).to eq 'value'
        end
      end

      describe 'duration is set' do
        before do
          subject.class::COOKIE_CONFIG[:test_cookie] = { duration: 1.day }
        end
        before do
          @cookie_jar = HashWithIndifferentAccess.new
          controller.stub(:cookies).and_return @cookie_jar
        end

        it 'should set duration on cookie' do
          subject.send :write_cookie_value, :test_cookie, 'value', nil, true
          cookie = @cookie_jar[:test_cookie]
          expect(cookie[:expires].to_s).to eq 1.day.from_now.to_s
        end
      end
    end
  end

  describe '#read_cookie_value' do
    before do
      @cookie_jar = HashWithIndifferentAccess.new
      controller.stub(:cookies).and_return @cookie_jar
    end

    after do
      subject.class::COOKIE_CONFIG.delete :test_cookie
    end

    it 'should read a simple value' do
      @cookie_jar[:test_cookie] = 'value'
      expect(subject.send :read_cookie_value, :test_cookie ).to eq 'value'
    end

    context 'when hash option is set true' do
      before do
        @cookie_jar[:test_cookie] = { test_key: 'test_value' }.to_json
      end
      it 'should read a json value as hash when no key provided' do
        expect(subject.send :read_cookie_value, :test_cookie, nil, hash: true).to be_a Hash
        expect(subject.send :read_cookie_value, :test_cookie, nil, hash: true).to eq(test_key: 'test_value')
      end

      it 'should return a value from the hash if given a key' do
        expect(subject.send :read_cookie_value, :test_cookie, :test_key, hash: true).to eq 'test_value'
      end
    end

    context 'when hash is configured to true' do
      before do
        subject.class::COOKIE_CONFIG[:test_cookie] = { hash: true }
        @cookie_jar[:test_cookie] = { test_key: 'test_value' }.to_json
      end

      it 'should read a json value as hash when no key provided' do
        expect(subject.send :read_cookie_value, :test_cookie).to be_a Hash
        expect(subject.send :read_cookie_value, :test_cookie).to eq(test_key: 'test_value')
      end

      it 'should return a value from the hash if given a key' do
        expect(subject.send :read_cookie_value, :test_cookie, :test_key).to eq 'test_value'
      end
    end

  end






end