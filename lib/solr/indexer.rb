# frozen_string_literal: true

module Solr
  class Indexer
    attr_reader :client
    attr_accessor :num_of_indexed_docs

    def self.with_solr_url(url)
      new(solr_client: RSolr.connect(url: url), schema: Schema.with_url(url))
    end

    def self.with_rw_client
      new(solr_client: Client.rw)
    end

    #######################################################################################33

    def initialize(solr_client:, schema:nil)
      @client = solr_client
      @schema = schema || Schema.with_rw_client
      @num_of_indexed_docs = 0
    end

    def index(indexables)
      raise ArgumentError.new("Must provide indexable items, given nil") unless indexables
      return unless indexables.any?
      first_indexable = indexables.next
      first_indexable.class.all_fields.each { |f| @schema.add_field(f) unless @schema.field_exists?(f) }
      num_of_index = 0
      indexables.each do |indexable| 
        index_one(indexable)
        @num_of_indexed_docs += 1
      end
      num_of_indexed_docs
    end

    def index_one(indexable)
      client.add(indexable.field_values)
    end

    def delete_all_by_type(indexable_class)
      unless indexable_class && indexable_class.respond_to?(:document_type)
        raise ArgumentError.new("Must provide class that is indexable")
      end
      client.delete_by_query("type:#{indexable_class.document_type}")
    end

    def delete_all
      client.delete_by_query("*:*")
    end

    def commit
      client.commit
    end

    def optimize
      client.optimize
    end

  end
end
