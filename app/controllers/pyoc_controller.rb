class PyocController <  ApplicationController
  SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)
  include GradeLevelConcerns

  def print_pdf
    # @db_schools = School.on_db(state_param.downcase.to_sym).where(active: true).order(name: :desc)
    # @db_schools = @db_schools[0..5]

    @db_schools = School.for_states_and_ids([state_param.downcase.to_sym,state_param.downcase.to_sym, state_param.downcase.to_sym], [params[:id1],params[:id2], params[:id3]])


    # @db_schools.each do |school|
    #   if school.collection.present? && school.collection.id == params[:collection_id]
    #     puts 'I am happy'
    #
    #     puts school.id
    #   end
    # end

    # @school_list_for_pdf = School.for_states_and_ids(['mi','wi', 'wi', 'wi', 'wi', 'in', 'wi'], [1273,2, 1110, 1030, 110, 428, 3573])
    # @db_schools = School.for_states_and_ids(['wi', 'wi', 'wi'], [217,219,2226])

    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    @db_schools.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query

    @school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    @schools_with_cache_results= @school_cache_results.decorate_schools(@db_schools)
    @schools_decorated_with_cache_results = @schools_with_cache_results.map do |school|
      PyocDecorator.decorate(school)
    end

      respond_to do |format|
      format.html
      format.pdf do
        pdf = PyocPdf.new(@schools_decorated_with_cache_results)
        send_data pdf.render, filename: 'hello',
                  type: 'application/pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
    end

    # render 'pyoc/print_pdf'

  end

end