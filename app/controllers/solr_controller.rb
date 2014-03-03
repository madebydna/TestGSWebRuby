class SolrController < ApplicationController
  def school_search
    # # Direct connection
    # solr = RSolr.connect :url => 'http://solrserver.com'

    # # Connecting over a proxy server
    # solr = RSolr.connect :url => 'http://solrserver.com', :proxy=>'http://user:pass@proxy.example.com:8080'

    # # send a request to /select
    # response = solr.get 'select', :params => {:q => '*:*'}

    # # send a request to /catalog
    # response = solr.get 'catalog', :params => {:q => '*:*'}
  end
end
