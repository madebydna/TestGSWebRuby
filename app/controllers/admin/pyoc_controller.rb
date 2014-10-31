class Admin::PyocController <  ApplicationController
  SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)



  def print_pdf

    @db_schools = find_schools_to_be_printed
    if (@db_schools.present?)
    schools_decorated_with_cache_results=prep_data_for_pdf(@db_schools)
    generate_pdf(schools_decorated_with_cache_results)
    else
      generate_empty_pdf
    end
    # rails runner script/generate_pyoc_pdf.rb wi 2 is_high_school 9 1
    # render 'pyoc/print_pdf'

  end


  def choose
    @db_schools = find_schools_to_be_printed
    render 'pyoc/show'

  end


  def generate_empty_pdf
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        pdf.text "Invalid Request Parameters"
        send_data pdf.render, filename: Time.now.strftime("%m%d%Y")+'_pyoc',
                  type: 'application/pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
    end
  end

  def find_schools_to_be_printed
    db_schools = []

    # binding.pry;
    if state_param.present? && params[:collection_id].present? && params[:is_high_school].present? && params[:is_high_school].length >0
        school_ids = SchoolMetadata.school_ids_for_collection_ids(state_param, params[:collection_id])
        db_schools = School.on_db(state_param).active.where(id: school_ids).order(name: :asc).to_a
        db_schools.select!(&:includes_highschool?)

    elsif state_param.present? && params[:collection_id].present? && params[:is_k8].present? && params[:is_k8].length>0
        school_ids = SchoolMetadata.school_ids_for_collection_ids(state_param, params[:collection_id])
        db_schools = School.on_db(state_param).active.where(id: school_ids).order(name: :asc).to_a
        db_schools.select!(&:pk8?)


    elsif state_param.present? && params[:collection_id].present? &&  !params[:is_k8].present?   &&  !params[:is_high_school].present?
        school_ids = SchoolMetadata.school_ids_for_collection_ids(state_param, params[:collection_id])
        db_schools = School.on_db(state_param).active.where(id: school_ids).order(name: :asc)

    elsif   state_param.present? && (params[:id1].present? || params[:id2].present? || params[:id3].present? || params[:id4].present?)
      db_schools = School.for_states_and_ids([state_param, state_param, state_param,state_param], [params[:id1], params[:id2], params[:id3],params[:id4]])
      end

      # Add schools
      if params[:added_schools].present?  && params[:added_schools].length > 0
        schools_to_be_added = params[:added_schools].split(',')
        db_schools += School.on_db(state_param).where(id: schools_to_be_added).all
        db_schools.sort! { |a,b| a.name <=> b.name }
      end

      # Remove schools
      if params[:removed_schools].present?  && params[:removed_schools].length > 0
        schools_to_be_removed = params[:removed_schools].split(',')
        db_schools -= School.on_db(state_param).where(id: schools_to_be_removed).all
        db_schools.sort! { |a,b| a.name <=> b.name }
      end
      db_schools
    end




  def prep_data_for_pdf(db_schools)
    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    db_schools.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query

    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    schools_with_cache_results= school_cache_results.decorate_schools(db_schools)
    schools_decorated_with_cache_results = schools_with_cache_results.map do |school|
      PyocDecorator.decorate(school)
    end
  end

  def generate_pdf(schools_decorated_with_cache_results)
    respond_to do |format|
      format.html
      format.pdf do
           pdf = PyocPdf.new(schools_decorated_with_cache_results, params[:is_k8].present?, params[:is_high_school].present?,
                             get_page_number_start,params[:language].present?  && params[:language] == 'spanish'? true : false)

           send_data pdf.render, filename: Time.now.strftime("%m%d%Y")+'_pyoc',
                  type: 'application/pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
    end
  end





  def get_page_number_start
    if params[:page_number_start].present?
      params[:page_number_start].to_i
    else
      1
    end
  end


end