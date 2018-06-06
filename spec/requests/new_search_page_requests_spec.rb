# frozen_string_literal: true

require 'spec_helper'

describe 'New search page' do
  context 'with no solr results' do
    before do
      stub_request(:post, /\/main\/select/).
        to_return(status: 200, body: {response: {docs: []}}.to_json, headers: {})
    end

    [
      ['/search/search.page?newsearch&q=foo', true],
      ['/search/search.page?newsearch&lat=1&lon=2', true],
      ['/search/search.page?newsearch&lat=1&lon=2&radius=3', true],
      ['/search/california/alameda/?newsearch', false],
      ['/search/california/alameda/?newsearch&q=bay', false],
      ['/search/california/alameda/alameda-unified-school-district/?newsearch&q=bay', false]
    ].each do |path, should_write_noindex|
      it "the uri: #{path} should #{should_write_noindex ? '' : 'not'} include noindex tag" do
        get path
        if should_write_noindex
          expect(response.body).to include('<meta name="robots" content="noindex" />')
        else
          expect(response.body).to_not include('<meta name="robots" content="noindex" />')
        end
      end
    end

  end
end