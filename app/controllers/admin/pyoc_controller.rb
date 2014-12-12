class Admin::PyocController <  ApplicationController

  include PdfConcerns

  def print_pdf

@db_schools = find_schools_to_be_printed(
        state_param,{
        :collection_id=>params[:collection_id].to_i,
        :is_high_school=>params[:batch] == 'is_high_school',
        :is_k8=>params[:batch] == 'is_k8',
        :is_pk8=>params[:batch] == 'is_pk8' ,
        :added_schools=>params[:added_schools],
        :removed_schools=>params[:removed_schools],
        :grade_level_for_index=>params[:grade_level_for_index],
        :id1=>params[:id1].to_i,
        :id2=>params[:id2].to_i,
        :id3=>params[:id3].to_i,
        :id4=>params[:id4].to_i}
    )
    # @db_schools =@db_schools[0..20]
    if (@db_schools.present?)
    schools_decorated_with_cache_results=prep_data_for_pdf(@db_schools)
    generate_pdf(schools_decorated_with_cache_results)
    else
      generate_empty_pdf
    end
  end


  def choose
    @db_schools = find_schools_to_be_printed(
        state_param,{
        :collection_id=>params[:collection_id].to_i,
        :is_high_school=>params[:batch] == 'is_high_school',
        :is_k8=>params[:batch] == 'is_k8',
        :is_pk8=>params[:batch] == 'is_pk8' ,
        :added_schools=>params[:added_schools],
        :removed_schools=>params[:removed_schools],
        :grade_level_for_index=>params[:grade_level_for_index],
        :id1=>params[:id1].to_i,
        :id2=>params[:id2].to_i,
        :id3=>params[:id3].to_i,
        :id4=>params[:id4].to_i}
       )
    set_meta_tags title:       "Choosing schools for Print your own chooser",
                  description: "Choosing schools for Print your own chooser",
                  keywords:    "Choosing schools for Print your own chooser"
    render 'pyoc/show'

  end


  def generate_empty_pdf
    respond_to do |format|
      format.pdf do
        pdf = Prawn::Document.new(:page_size => [621, 801])
        pdf.text "Invalid Request Parameters"
        send_data pdf.render, filename: Time.now.strftime("%m%d%Y")+'_pyoc.pdf',

                  type: 'application/pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
    end
  end


  def generate_pdf(schools_decorated_with_cache_results)
    respond_to do |format|
      format.pdf do
           pdf = PyocPdf.new(schools_decorated_with_cache_results,
                             {
                             :is_k8_batch => params[:batch] == 'is_k8',
                             :is_high_school_batch => params[:batch] == 'is_high_school',
                             :is_pk8_batch => params[:batch] == 'is_pk8',
                             :get_page_number_start => params[:page_number_start],
                             :is_spanish => params[:language].present?  && params[:language] == 'spanish'? true : false ,
                             :collection_id => params[:collection_id].present? ? params[:collection_id].to_i: nil,
                             :is_location_index => params[:is_location_index].present? ,
                             :is_performance_index => params[:is_performance_index].present? ,
                             :location_index_page_number_start =>params[:location_index_page_number_start],
                             :performance_index_page_number_start => params[:performance_index_page_number_start]
                            }

           )


           send_data pdf.render, filename: Time.now.strftime("%m%d%Y")+'_pyoc.pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
    end
  end


end