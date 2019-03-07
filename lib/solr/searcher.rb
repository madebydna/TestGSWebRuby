module Solr
  class Searcher
    def self.rsolr
      @_client = Client.ro
    end

    def initialize(rsolr: self.class.rsolr)
      @rsolr = rsolr
    end

    def print_request(query)
      req = @rsolr.build_request('select', query.params)
      uri = req[:uri]
      uri.query = req.except(:uri,:query,:method,:path,:params).to_params
      puts '-' * 60
      puts "Solr query:\n"
      puts uri.to_s
      puts '-' * 60
      return uri.to_s
    end

    def search(query)
      begin
        print_request(query)
        res = @rsolr.post(
          'select',
          data: query.params
        )
        docs = res.dig('response', 'docs')
        if query.document_class
          docs.map! { |doc| query.document_class.from_hash(doc) }
          docs.extend(query.document_class.const_get('CollectionMethods'))
        end
        Response.new(
          total: res.dig('response', 'numFound'),
          results: docs,
          **(res['facet_counts']&.symbolize_keys || {})
        )
      rescue => e
        puts "Exception when querying solr #{print_request(query)}"
        raise e
      end
    end
  end
end

