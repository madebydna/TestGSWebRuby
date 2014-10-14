class PyocController <  ApplicationController
  SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)
  include GradeLevelConcerns
  include  LevelCodeConcerns

  def print_pdf
    if state_param.present? && (params[:id1].present? || params[:id1].present? || params[:id1].present?)
    @db_schools = School.for_states_and_ids([state_param,state_param, state_param], [params[:id1],params[:id2], params[:id3]])
    elsif state_param.present? && params[:collection_id].present?
    @db_schools = School.on_db(state_param).where(active: true).order(name: :asc)
    @db_schools = @db_schools[0..5]
    @db_schools.each do |school|
      if !(school.collection.present? && school.collection.id == params[:collection_id].to_i  && (school.level_code.to_s.include? "m" or school.level_code.to_s.include? "e" or school.level_code.to_s.include? "p"))
        @db_schools -= Array[school]
      end
    end
    elsif state_param.present?
      @db_schools = School.on_db(state_param).where(active: true).order(name: :asc)
      @db_schools = @db_schools[0..5]

    end


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