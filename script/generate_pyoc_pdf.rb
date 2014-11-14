class GeneratePyocPdf

include PdfConcerns

  def generate_pdf

        db_schools = find_schools_to_be_printed('wi',{:collection_id=>2})



        @schools_decorated_with_cache_results= prep_data_for_pdf(db_schools)


        # pdf = PyocPdf.new(@schools_decorated_with_cache_results, @high_school_or_k8=='is_k8'? true :false , @high_school_or_k8=='is_high_school'?true:false, @page_start,@is_spanish.present? ? true : false)
        # pdf.render_file  Time.now.strftime("%m%d%Y")+'_'+@state+'_'+@collection_id+'_'+@high_school_or_k8+'_pyoc.pdf'

        pdf = PyocPdf.new(@schools_decorated_with_cache_results,true,false,10,true)
        time = Time.now.strftime("%m%d%Y")
        pdf.render_file("#{time}_wi_2_XXX_pyoc.pdf")

  end


  def usage
        abort "\nUSAGE: rails runner script/generate_pyoc_pdf  [state]:[collection_id]:is_high_school:[page_start]
      or
      \nUSAGE: rails runner script/generate_pyoc_pdf  [state]:[collection_id]:is_k8:[page_start]
      Ex: rails runner script/generate_pyoc_pdf wi:2:is_high_school:0
      rails runner script/generate_pyoc_pdf wi:2:is_k8:9
      For Spanish
      rails runner script/generate_pyoc_pdf wi:2:is_k8:9:1
      "
  end

end

GeneratePyocPdf.new.generate_pdf

