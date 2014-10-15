class PyocController <  ApplicationController
  SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)


  def print_pdf
    if state_param.present? && (params[:id1].present? || params[:id1].present? || params[:id1].present?)
    @db_schools = School.for_states_and_ids([state_param,state_param, state_param], [params[:id1],params[:id2], params[:id3]])
    elsif state_param.present? && params[:collection_id].present? && params[:is_high_school].present?
    @db_schools_full = School.on_db(state_param).where(active: true).order(name: :asc)
    @db_schools = []
    @db_schools_full.each do |school|
      if school.collection.present? && school.collection.id == params[:collection_id].to_i  && is_high_school(school)
        @db_schools.push(school)
      end
    end
    elsif state_param.present? && params[:collection_id].present? && params[:is_k8].present?
      @db_schools_full = School.on_db(state_param).where(active: true).order(name: :asc)
      @db_schools = []
      @db_schools_full.each do |school|
        if school.collection.present? && school.collection.id == params[:collection_id].to_i  && is_k8(school)
          @db_schools.push(school)
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
        pdf = PyocPdf.new(@schools_decorated_with_cache_results,params[:is_k8].present?,params[:is_high_school].present?)
        send_data pdf.render, filename:Time.now.strftime("%m%d%Y")+'_pyoc',
                  type: 'application/pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
      end



    # render 'pyoc/print_pdf'

  end
  private

  def is_k8(school)
    level_code_string=school.level_code.to_s
    if   level_code_string.include? "m" or level_code_string.include? "e" or level_code_string.include? "p"
      true
    else
      false
    end


  end

  def is_high_school(school)
    level_code_string=school.level_code.to_s
    if  level_code_string.include? "h"
      true
    else
      false
    end
  end
end