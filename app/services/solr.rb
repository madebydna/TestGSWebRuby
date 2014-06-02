class Solr
  def initialize(state_short, collection_id)
    @state_short, @collection_id = state_short, collection_id
    @connection = RSolr.connect(url: ENV_GLOBAL['solr.ro.server.url'])
  end

  def breakdown_results(options)
    cache_key = "breakdown_results-state:#{@state_short}-collection_id:#{@collection_id}-options:#{options.to_s}"
    Rails.cache.fetch(cache_key, expires_in: cache_time, race_condition_ttl: cache_time) do
      begin
        response = @connection.get "select/", params: parse_params(options)
        results = { count: response['response']['numFound'], path: parse_url(options) }
      rescue => e
        Rails.logger.error('Reaching the solr server failed:' + e.to_s)
        results = nil
      end
    end
  end

  private

    def cache_time
      LocalizedProfiles::Application.config.hub_mapping_cache_time.minutes.from_now
    end

    def parse_params(options)
      params = { qt: 'school-search', fq: ["+school_database_state:#{@state_short}", "+collection_id:\"#{@collection_id}\""] }
      params[:fq] << "+school_grade_level:(#{options[:grade_level]})" if options[:grade_level]
      params[:fq] << "+school_type:(#{options[:type]})" if options[:type]
      params
    end

    def parse_url(options)
      url = "schools"
      url += "/?gradeLevels=#{options[:grade_level]}" if options[:grade_level]
      if options[:type].try(:index, 'OR') # public or charter
        if options[:grade_level]
          url += "&st=public&st=charter"
        else
          url += "/?st=public&st=charter"
        end
      else
        if options[:type]
          if options[:grade_level]
            url += "&st=#{options[:type]}"
          else
            url += "/?st=#{options[:type]}"
          end
        end
      end
      url
    end
end
