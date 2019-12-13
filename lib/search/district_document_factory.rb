# frozen_string_literal: true

module Search
  class DistrictDocumentFactory
    def initialize(states: States.abbreviations, ids: nil)
      @states = states
      @ids = ids
    end

    def documents
      lazy_enum = @states # strings
              .lazy # dont make DistrictDocuments until enumerated
              .flat_map do |state|
            ids = @ids.presence || ids_for_state(state)
            [state].product(ids) # [state, id] pairs
          end
      lazy_enum.map do |state, district_id|
        Solr::DistrictDocument.new(state: state, district_id: district_id)
      end
    end

    private

    def ids_for_state(state)
      DistrictRecord.by_state(state.downcase).active.where(charter_only: 0).pluck(:district_id)
    end
  end
end