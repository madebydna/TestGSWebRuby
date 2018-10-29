# frozen_string_literal: true

module Solr
  class Indexer
    attr_reader :client

    def self.with_solr_url(url)
      new(solr_client: RSolr.connect(url: url))
    end

    def self.with_rw_client
      new(solr_client: Client.rw)
    end

    #######################################################################################33

    def initialize(solr_client:)
      @client = solr_client
      @schema = Schema.with_rw_client
    end

    def index(indexables)
      raise ArgumentError.new("Must provide indexable items, given nil") unless indexables
      return unless indexables.any?
      first_indexable = indexables.next
      first_indexable.class.all_fields.each { |f| @schema.add_field(f) unless @schema.field_exists?(f) }
      indexables.each { |indexable| index_one(indexable) }
    end

    def index_one(indexable)
      solr_field_values = indexable.field_values.each_with_object({}) do |(f, v), hash|
        hash[f.name] = v
      end
      client.add(solr_field_values)
    end

    def delete_all_by_type(indexable_class)
      unless indexable_class && indexable_class.respond_to?(:type)
        raise ArgumentError.new("Must provide class that is indexable")
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
