require 'spec_helper'
describe ApplicationController do

  it 'should have methods for manipulating cookies' do
    expect(controller).to respond_to(:write_cookie_value)
    expect(controller).to respond_to(:read_cookie_value)
    expect(controller).to respond_to(:delete_cookie)
  end

  describe '#write_cookie_value' do
    before { subject.class::COOKIE_CONFIG[:test_cookie] = {} }
    after { subject.class::COOKIE_CONFIG.delete :test_cookie }

    it 'should set a simple value' do
      subject.send :write_cookie_value, :test_cookie, 'value'
      expect(cookies['test_cookie']).to eq('value')
    end

    it 'should not overwrite cookie when asked not to' do
      subject.send :write_cookie_value, :test_cookie, 'value'
      subject.send :write_cookie_value,
                   :test_cookie,
                   'new value should not overwrite',
                   nil,
                   false
      expect(cookies['test_cookie']).to eq 'value'
    end

    context 'when given options' do
      describe 'option "hash" is true' do
        it 'cookie key and value should be saved as json' do
          subject.send :write_cookie_value,
                       :test_cookie,
                       'value',
                       'key',
                       true,
                       hash: true
          expect(cookies['test_cookie']).to eq({ key: 'value' }.to_json)
        end

        it 'should not save cookie as json if caller doesnt provide key' do
          subject.send :write_cookie_value,
                       :test_cookie,
                       'value',
                       nil,
                       true,
                       hash: true
          expect(cookies['test_cookie']).to eq 'value'.to_json
        end
      end

      describe 'option "hash" is false' do
        it 'should set cookie value as string and key is ignored' do
          subject.send :write_cookie_value,
                       :test_cookie,
                       'value',
                       'key',
                       true,
                       hash: false
          expect(cookies['test_cookie']).to eq 'value'
        end
      end

      describe 'duration is set' do
        before do
          @cookie_jar = HashWithIndifferentAccess.new
          allow(controller).to receive(:cookies).and_return @cookie_jar
        end

        it 'should set duration on cookie' do
          test_duration = 1.day
          subject.send :write_cookie_value,
                       :test_cookie,
                       'value',
                       nil,
                       true,
                       duration: test_duration
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
          allow(controller).to receive(:cookies).and_return @cookie_jar
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
      subject.class::COOKIE_CONFIG[:test_cookie] = {}
      allow(controller).to receive(:cookies).and_return @cookie_jar
    end

    after do
      subject.class::COOKIE_CONFIG.delete :test_cookie
    end

    it 'should read a simple value' do
      @cookie_jar[:test_cookie] = 'value'
      expect(subject.send :read_cookie_value, :test_cookie).to eq 'value'
    end

    context 'when hash option is set true' do
      before do
        @cookie_jar[:test_cookie] = { test_key: 'test_value' }.to_json
      end
      it 'should read a json value as hash when no key provided' do
        expect(subject.send :read_cookie_value, :test_cookie, nil, hash: true)
          .to be_a Hash
        expect(subject.send :read_cookie_value, :test_cookie, nil, hash: true)
          .to eq(test_key: 'test_value')
      end

      it 'should return a value from the hash if given a key' do
        expect(subject.send :read_cookie_value,
                            :test_cookie,
                            :test_key,
                            hash: true
                            ).to eq 'test_value'
      end
    end

    context 'when hash is configured to true' do
      before do
        subject.class::COOKIE_CONFIG[:test_cookie] = { hash: true }
        @cookie_jar[:test_cookie] = { test_key: 'test_value' }.to_json
      end

      it 'should read a json value as hash when no key provided' do
        expect(subject.send :read_cookie_value, :test_cookie).to be_a Hash
        expect(subject.send :read_cookie_value, :test_cookie)
          .to eq(test_key: 'test_value')
      end

      it 'should return a value from the hash if given a key' do
        expect(subject.send :read_cookie_value, :test_cookie, :test_key)
          .to eq 'test_value'
      end
    end

  end

  describe '#delete_cookie' do
    class CookieJar < HashWithIndifferentAccess
      def delete(key, *args)
        super key
      end
    end

    before do
      @cookie_jar = CookieJar.new
      allow(controller).to receive(:cookies).and_return @cookie_jar
    end

    it 'should read a simple value' do
      @cookie_jar[:test_cookie] = 'value'
      subject.send :delete_cookie, :test_cookie
      expect(@cookie_jar[:test_cookie]).to be_nil
    end

    context 'when hash option is configured to true' do
      before do
        @cookie_jar[:test_cookie] = { test_key: 'test_value' }.to_json
        subject.class::COOKIE_CONFIG[:test_cookie] = {
          hash: true
        }
      end
      it 'should delete cookie when no key provided' do
        subject.send :delete_cookie, :test_cookie
        expect(@cookie_jar[:test_cookie]).to be_nil
      end

      it 'should delete a value from the hash if given a key' do
        @cookie_jar[:test_cookie] =
          { test_key: 'foo', another_key: 'bar' }.to_json
        subject.send :delete_cookie, :test_cookie, :test_key
        expect(@cookie_jar[:test_cookie])
          .to eq(
            {
              'value' => {
                'another_key' => 'bar'
              }.to_json,
              'domain' => :all
            }
          )
      end
    end
  end

  describe '#flash_message' do
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

  describe '#exception_handler' do
    controller do
      def routing_error
        raise ActionController::RoutingError.new 'should trigger 404'
      end
      def runtime_error
        raise RuntimeError.new 'should trigger 500'
      end
    end

    before { Rails.application.config.consider_all_requests_local = false }
    after { Rails.application.config.consider_all_requests_local = true }

    it 'should render Page Not Found' do
      routes.draw { get 'routing_error' => 'anonymous#routing_error' }
      get :routing_error
      expect(response).to render_template 'error/page_not_found'
    end

    it 'should render Internal Error page' do
      routes.draw { get 'runtime_error' => 'anonymous#runtime_error' }
      get :runtime_error
      expect(response).to render_template 'error/internal_error'
    end

    it 'should pass through error by default' do
      routes.draw { get 'routing_error' => 'anonymous#routing_error' }
      Rails.application.config.consider_all_requests_local = true
      expect{ get :routing_error }
        .to raise_error(ActionController::RoutingError)
    end
  end

  describe '#adapt_flash_messages_from_java' do
    it 'method should be defined' do
      expect(controller).to respond_to :adapt_flash_messages_from_java
    end

    it 'should handle the flash_notice cookie' do
      cookies[:flash_notice_key] = 'foo.bar.baz'
      allow(controller).to receive(:t).and_return 'Foo'
      controller.send(:adapt_flash_messages_from_java)
      expect(flash[:notice].first).to eq('Foo')
    end

    it 'should translate the given key' do
      cookies[:flash_notice_key] = 'foo.bar.baz'
      expect(controller).to receive(:t)
      controller.send(:adapt_flash_messages_from_java)
    end
  end

  describe '#path_w_query_string' do
    context 'from school profile' do
      let (:profile_url) { 'http://www.greatschools.org/california/alameda/1-Alameda-High-School/' }
      it 'handles reviews tab with no params' do
        allow(request).to receive(:original_url).and_return profile_url
        expect(controller.send(:path_w_query_string, 'tab', 'reviews')).to eq profile_url + 'reviews/'
      end
      it 'handles reviews tab with some params' do
        allow(request).to receive(:original_url).and_return profile_url + '?a=b&c=d'
        expect(controller.send(:path_w_query_string, 'tab', 'reviews')).to eq profile_url + 'reviews/?a=b&c=d'
      end
      it 'handles reviews tab with some params stripping tab' do
        allow(request).to receive(:original_url).and_return profile_url + '?a=b&c=d&tab=reviews'
        expect(controller.send(:path_w_query_string, 'tab', 'reviews')).to eq profile_url + 'reviews/?a=b&c=d'
      end
    end
    context 'from city browse' do
      let (:search_url) { 'http://www.greatschools.org/california/alameda/schools/' }
      it 'handles search browse' do
        allow(request).to receive(:original_url).and_return search_url
        expect(controller.send(:path_w_query_string, 'sort', nil)).to eq search_url
      end
      it 'handles search browse with common params' do
        allow(request).to receive(:original_url).and_return search_url + '?grades=k&page=2&st=public'
        expect(controller.send(:path_w_query_string, 'sort', nil)).to eq search_url + '?grades=k&page=2&st=public'
      end
      it 'handles search browse with common params and sort' do
        allow(request).to receive(:original_url).and_return search_url + '?grades=k&page=2&sort=fit_desc&st=public'
        expect(controller.send(:path_w_query_string, 'sort', nil)).to eq search_url + '?grades=k&page=2&st=public'
      end
    end
    context 'from search by location' do
      let (:search_url) { 'http://www.greatschools.org/search.page?distance=15&lat=123&locationSearchString=94111&lon=456' }
      it 'handles search browse' do
        allow(request).to receive(:original_url).and_return search_url
        expect(controller.send(:path_w_query_string, 'sort', nil)).to eq search_url
      end
      it 'handles search browse with common params' do
        allow(request).to receive(:original_url).and_return search_url + '&grades=k&page=2&st=public'
        expect(controller.send(:path_w_query_string, 'sort', nil)).to eq 'http://www.greatschools.org/search.page?distance=15&grades=k&lat=123&locationSearchString=94111&lon=456&page=2&st=public'
      end
      it 'handles search browse with common params and sort' do
        allow(request).to receive(:original_url).and_return search_url + '&grades=k&page=2&st=public&sort=fit_desc'
        expect(controller.send(:path_w_query_string, 'sort', nil)).to eq 'http://www.greatschools.org/search.page?distance=15&grades=k&lat=123&locationSearchString=94111&lon=456&page=2&st=public'
      end
    end
  end
end
