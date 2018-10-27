module Solr
  class Response
    attr_reader :total, :results, :facet_fields

    def initialize(total:, results:[], facet_queries: {}, facet_fields: {}, facet_ranges: {}, facet_intervals: {}, facet_heatmaps: {})
      @total = total
      @results = results
      @facet_queries = facet_queries
      @facet_fields = facet_fields
      @facet_ranges = facet_ranges
      @facet_intervals = facet_intervals
      @facet_heatmaps = facet_heatmaps
    end

    def facet_counts_for_field(field)
      facet_fields[field] || []
    end
  end
end