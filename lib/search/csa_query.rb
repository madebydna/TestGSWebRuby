# frozen_string_literal: true

module Search
  class CSAQuery < SolrSchoolQuery
    def facet_fields
      ['csa_badge']
    end
  end
end