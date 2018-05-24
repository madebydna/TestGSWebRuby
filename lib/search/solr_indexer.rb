# frozen_string_literal: true

module Search
  class SolrIndexer
    attr_reader :client

    def self.with_rsolr_client(url)
      new(solr_client: RSolr.connect(url: url))
    end

    def initialize(solr_client:)
      @client = solr_client
    end

    def index(indexables)
      raise ArgumentError.new('Must provide indexable items, given nil') unless indexables

      indexables.each do |indexable|
        data = indexable.to_h
        client.add(data) if data.present?
      end
    end

    def delete_all_by_type(indexable_class)
      unless indexable_class && indexable_class.respond_to?(:type)
        raise ArgumentError.new('Must provide class that is indexable')
      end
      client.delete_by_query("type:#{indexable_class.type}")
    end

    def commit
      client.commit
    end

    def optimize
      client.optimize
    end

  end
end
