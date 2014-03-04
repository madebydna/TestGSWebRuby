class Solr
  def initialize(state_short, collection_id)
    @state_short = state_short
    @collection_id = collection_id
    @solr = RSolr.connect(url: ENV_GLOBAL['solr_url'])
  end

  def city_hub_breakdown_results(options)
    cache_key = "city_hub_breakdown_results-state:#{@state_short}-collection_id:#{@collection_id}-options:#{options.to_s}"
    Rails.cache.fetch(cache_key, expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
      result = @solr.get "/main/select/", params: parse_params(options)

      { count: result['response']['numFound'], path: parse_url(options) }
    end
  end

  private

    def parse_params(options)
      params = { qt: 'school-search', fq: ["+school_database_state:#{@state_short}", "+collection_id:\"#{@collection_id}\""] }
      params[:fq] << "+school_grade_level:(#{options[:grade_level]})" if options[:grade_level]
      params[:fq] << "+school_type:(#{options[:type]})" if options[:type]
      params
    end

    def parse_url(opts)
      url = "schools"
      url += "/?gradeLevel=#{opts[:grade_level]}" if opts[:grade_level]
      if opts[:type].try(:index, 'OR') # public or private
        url += "/?st=public&st=private"
      else
        url += "/?st=#{opts[:type]}" if opts[:type]
      end
      url
    end
end
