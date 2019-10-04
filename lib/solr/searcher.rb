module Solr
  class Searcher
    def self.rsolr
      @_client = Client.ro
    end

    def initialize(rsolr: self.class.rsolr)
      @rsolr = rsolr
    end

    def print_request(res)
      uri = res.request[:uri].to_s + '&' + res.request[:data]
      # puts '-' * 60
      puts "\e[35m-\e[0m" * 60
      puts "\e[35mSolr query:\n\e[0m"
      puts uri.to_s
      puts "\e[36m#{uri.to_s}\e[0m"
      puts "\e[35m-\e[0m" * 60
      return uri.to_s
    end

    def search(query)
      begin
        res = @rsolr.post(
          'select',
          data: query.params
        )
        # print_request(res)
        if res.has_key?('grouped')
          total = res['grouped'].values.inject(0) { |sum, g| sum += g.dig('matches').to_i }
          docs = res['grouped'].values.inject([]) { |d, g| d += g.dig('doclist', 'docs') }
          Response.new(
            total: total,
            results: docs,
            **(res['facet_counts']&.symbolize_keys || {})
          )
        else
          docs = res.dig('response', 'docs') || []
          if query.document_class
            docs.map! { |doc| query.document_class.from_hash(doc) }
            docs.extend(query.document_class.const_get('CollectionMethods'))
          end
          Response.new(
            total: res.dig('response', 'numFound'),
            results: docs,
            **(res['facet_counts']&.symbolize_keys || {})
          )
        end
      rescue => e
        puts "Exception when querying solr"
        raise e
      end
    end
  end
end

