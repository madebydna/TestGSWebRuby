module Solr
  class Searcher
    def self.rsolr
      @_client = Client.ro
    end

    def initialize(rsolr: self.class.rsolr)
      @rsolr = rsolr
    end

    def search(query)
      res = @rsolr.post(
        'select',
        data: query.params
      )
      docs = res.dig('response', 'docs')
      if query.document_type
        docs.map! { |doc| query.document_type.from_hash(doc) }
        docs.extend(query.document_type.const_get('CollectionMethods'))
      end
      Response.new(
        total: res.dig('response', 'numFound'),
        results: docs,
        **(res['facet_counts']&.symbolize_keys || {})
      )
    end
  end
end

