# frozen_string_literal: true

module Search
  class SchoolDocumentFactory
    def initialize(states: States.abbreviations, ids: nil)
      @states = states
      @ids = ids
    end

    def documents
      lazy_enum = 
        @states # strings
        .lazy # dont make SchoolDocuments until enumerated
        .flat_map do |state|
          ids = @ids.presence || ids_for_state(state)
          [state].product(ids) # [state, id] pairs
        end
      lazy_enum.map do |state, school_id|
        SchoolDocument.new(state: state, school_id: school_id)
      end
    end

    private

    def ids_for_state(state)
      School.on_db(state.downcase.to_sym).active.order(:id).select(:id)
    end
  end
end
