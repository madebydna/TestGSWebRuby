class Admin::PyocController <  ApplicationController

  include PdfConcerns

  def print_pdf
    @db_schools = find_schools_to_be_printed(
        state_param,
        params[:collection_id].to_i,
        params[:is_high_school].to_bool,
        params[:is_k8].to_bool,
        params[:is_pk8].to_bool,
        params[:added_schools],
        params[:removed_schools],
        params[:id1],
        params[:id2],
        params[:id3],
        params[:id4])
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
        state_param,
        params[:collection_id].to_i,
        params[:is_high_school].to_bool,
        params[:is_k8].to_bool,
        params[:is_pk8].to_bool,
        params[:added_schools],
        params[:removed_schools],
        params[:id1],
        params[:id2],
        params[:id3],
        params[:id4])
    set_meta_tags title:       "Choosing schools for Print your own chooser",
                  description: "Choosing schools for Print your own chooser",
                  keywords:    "Choosing schools for Print your own chooser"
    render 'pyoc/show'

  end


  def generate_empty_pdf
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        pdf.text "Invalid Request Parameters"
        send_data pdf.render, filename: Time.now.strftime("%m%d%Y")+'_pyoc.pdf',
                  type: 'application/pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
    end
  end






  def generate_pdf(schools_decorated_with_cache_results)
    respond_to do |format|
      format.html
      format.pdf do
           pdf = PyocPdf.new(schools_decorated_with_cache_results, params[:is_k8].present?, params[:is_high_school].present?,params[:is_pk8].present?,
                             params[:page_number_start],params[:language].present?  && params[:language] == 'spanish'? true : false)

           send_data pdf.render, filename: Time.now.strftime("%m%d%Y")+'_pyoc.pdf',
                  type: 'application/pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
    end
  end


end