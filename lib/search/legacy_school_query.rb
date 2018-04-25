# frozen_string_literal: true

module Search
  class LegacySchoolQuery < SchoolQuery

    def search
      response = client.search(School, &sunspot_query)
      response.instance_variable_get(:@solr_result)['response']['docs'].each do |doc|
        key = SchoolDocument.unique_key(doc['school_database_state'].first, doc['school_id'])
        class_name = 'School'
        doc['id'] = "#{class_name} #{key}"
      end
      Results.new(response.results, self)
    end

    def sunspot_query
      lambda do |search|
        # Must reference accessor methods, not instance variables!
        search.with(:citykeyword, city.downcase) if city
        search.with(:school_database_state, state.downcase) if state
        search.paginate(page: page, per_page: 25)
        search.order_by(:overall_gs_rating, :desc)
        search.adjust_solr_params do |params|
          params[:defType] = browse? ? 'lucene' : 'dismax'
          params[:qt] = 'school-search' unless browse?
          # the first criteria is type:School, but that field doesn't exist
          # replace it with the way we filter document types
          params[:fq][0] = 'document_type:school'
          params[:fq].map! do |param|
            param.sub(/_s(\W)/, '\1')
          end
          params[:sort] = params[:sort].sub(/_i(\W)/, '\1')
        end
      end
    end
  end
end
