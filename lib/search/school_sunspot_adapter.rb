# frozen_string_literal: true

module SchoolSunspotAdapter
  def self.hack_id_into_solr_docs(solr_response)
    solr_response.instance_variable_get(:@solr_result)['response']['docs'].each do |doc|
      key = SchoolSunspotAdapter.key_from_state_and_id(doc['school_database_state'].first, doc['school_id'])
      class_name = 'School'
      doc['id'] = "#{class_name} #{key}"
    end
  end

  def self.key_from_state_and_id(state, id)
    "#{state.downcase}-#{id}"
  end

  # if you change these classes you probably have to restart rails
  class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
    def id
      SchoolSunspotAdapter.key_from_state_and_id(@instance.state, @instance.id)
    end
  end

  class DataAccessor < Sunspot::Adapters::DataAccessor
    def load_all(ids)
      states_and_ids = ids.map { |id| id.split('-') }
      states = states_and_ids.map(&:first)
      ids = states_and_ids.map(&:last)
      School.for_states_and_ids(states, ids)
    end
  end
end

