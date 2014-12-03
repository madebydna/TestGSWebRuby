#encoding: utf-8
include PdfConcerns
include WritePdfConcerns

class PyocPdf < Prawn::Document


  # def initialize(schools_decorated_with_cache_results, is_k8_batch, is_high_school_batch, is_pk8_batch, get_page_number_start, is_spanish, collection_id, is_location_index, is_performance_index, location_index_page_number_start, performance_index_page_number_start)
  def initialize(schools_decorated_with_cache_results, opts = {})

    is_k8_batch = opts[:is_k8_batch ]
    is_high_school_batch = opts [:is_high_school_batch]
    is_pk8_batch = opts [:is_pk8_batch]
    get_page_number_start = opts[:get_page_number_start]
    is_spanish = opts[:is_spanish]
    collection_id = opts[:collection_id]
    is_location_index = opts[:is_location_index]
    is_performance_index = opts[:is_performance_index]
    location_index_page_number_start = opts[:location_index_page_number_start]
    performance_index_page_number_start = opts[:performance_index_page_number_start]


    @is_spanish=is_spanish
    super()

    if is_performance_index

      draw_index_page_title(is_spanish, 'Las escuelas más valoradas', 'Top rated schools')

      draw_performance_index_columns_on_page(is_spanish, schools_decorated_with_cache_results)

      draw_all_footer(performance_index_page_number_start, collection_id)

    elsif is_location_index

      draw_index_page_title(is_spanish, 'Escuelas por ubicación', 'Schools by location')

      draw_location_index_columns_on_page(schools_decorated_with_cache_results)

      draw_all_footer(location_index_page_number_start, collection_id)

    else
      generate_schools_pdf(get_page_number_start, is_high_school_batch, is_k8_batch, is_pk8_batch, schools_decorated_with_cache_results, collection_id)
    end

  end
end
