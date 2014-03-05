class Solr
  def self.city_hub_breakdown_results(state_short, collection_id, options)
    cache_key = "city_hub_breakdown_results-state:#{state_short}-collection_id:#{collection_id}-options:#{options.to_s}"
    Rails.cache.fetch(cache_key, expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
      begin
        solr = RSolr.connect(url: ENV_GLOBAL['solr_url'])
        response = solr.get "/main/select/", params: self.parse_params(state_short, collection_id, options)
        breakdown_results = { count: response['response']['numFound'], path: self.parse_url(options) }
      rescue => e
        breakdown_results = nil
        Rails.logger.error('Reaching the solr server failed:' + e.to_s)
      end
      breakdown_results
    end
  end

  private

    def self.parse_params(state_short, collection_id, options)
      params = { qt: 'school-search', fq: ["+school_database_state:#{state_short}", "+collection_id:\"#{collection_id}\""] }
      params[:fq] << "+school_grade_level:(#{options[:grade_level]})" if options[:grade_level]
      params[:fq] << "+school_type:(#{options[:type]})" if options[:type]
      params
    end

    def self.parse_url(options)
      url = "schools"
      url += "/?gradeLevel=#{options[:grade_level]}" if options[:grade_level]
      if options[:type].try(:index, 'OR') # public or private
        url += "/?st=public&st=private"
      else
        url += "/?st=#{options[:type]}" if options[:type]
      end
      url
    end
end
