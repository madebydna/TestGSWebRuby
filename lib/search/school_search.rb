# frozen_string_literal: true

Sunspot.config.solr.url = ENV_GLOBAL['solr.ro.server.url']
Sunspot::Adapters::InstanceAdapter.register(SchoolSunspotAdapter::InstanceAdapter, School)
Sunspot::Adapters::DataAccessor.register(SchoolSunspotAdapter::DataAccessor, School)
Sunspot.setup(School) do
  string :citykeyword
end


class SchoolSearch
  attr_writer :q, :district_id, :city, :page
  attr_reader :q, :district_id, :city, :page, :state

  extend Forwardable
  def_delegators :response, :results, :total
  def_delegators :results, :current_page, :total_pages, :per_page, :first_page?, :last_page?, :prev_page?, :next_page?, :offset, :out_of_bounds

    # :offset, :current_page, :total_pages, :per_page, :limit_value, :first_page?, :prev_page, :last_page?, :next_page, :total_count, :offset_value, :num_pages, :total_entries, :total_entries=, :total_count=, :previous_page, :out_of_bounds?, 

  def initialize(city:nil, state:nil, q:nil, district_id:nil, page:1)
    self.city = city
    self.state = state
    self.district_id = district_id
    self.q = q
    self.page = page
  end

  def response
    @_response ||= begin
      Sunspot.search(School, &sunspot_search_definition).tap do |response|
        SchoolSunspotAdapter.hack_id_into_solr_docs(response)
      end
    end
  end

  # accept state or state abbreviation
  def state=(state)
    return unless state.present?
    abbreviation = States.abbreviation(state)
    unless States.is_abbreviation?(abbreviation)
      raise ArgumentError.new("Not a valid state: #{state}")
    end
    @state = abbreviation
  end

  private

  def browse?
    state && (city || district_id)
  end

  def default_query_string
    browse? ? '*' : 'school'
  end

  def sunspot_search_definition
    lambda do |search|
      # Must reference accessor methods, not instance variables!
      search.keywords(q || default_query_string)
      search.with(:citykeyword, city) if city
      search.paginate page: page, per_page: 25
      search.adjust_solr_params do |params|
        params[:defType] = browse? ? 'lucene' : 'dismax'   
        params[:qt] = 'school-search' unless browse?
        # the first criteria is type:School, but that field doesn't exist
        # replace it with the way we filter document types
        params[:fq][0] = 'document_type:school'
        params[:fq].map! do |param|
          param.sub(/_s:/, ':')
        end
      end
    end
  end

end
