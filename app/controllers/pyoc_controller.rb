class PyocController <  ApplicationController
  SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)
  include GradeLevelConcerns

  def print_pdf
    @school_list_for_pdf = School.for_states_and_ids(['wi','wi'], [108,428])

    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    @school_list_for_pdf.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query

    @school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    @schools_with_cache_results= @school_cache_results.decorate_schools(@school_list_for_pdf)
    @schools_decorated_with_cache_results = @schools_with_cache_results.map do |school|
      PyocDecorator.decorate(school)
    end

      # respond_to do |format|
    #   format.html
    #   format.pdf do
    #     pdf = PrawnPdf.new(print_pdf_url)
    #     send_data pdf.render, filename: 'hello',
    #               type: 'application/pdf',
    #               disposition: 'inline' #loads pdf directly in browser window
    #   end
    # end

    render 'pyoc/print_pdf'

  end

end