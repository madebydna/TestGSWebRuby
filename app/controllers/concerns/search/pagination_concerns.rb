module PaginationConcerns
  extend ActiveSupport::Concern

  protected

  def set_page_instance_variables
    @results_offset = results_offset
    @page_size = page_size
    @page_number = page_number
  end

  def set_pagination_instance_variables(total_results)
    @max_number_of_pages = calc_max_number_of_pages(total_results) #for pagination and meta tags
    @window_size = calc_kaminari_window_size(@max_number_of_pages)
    @pagination = Kaminari.paginate_array([], total_count: total_results).page(page_number).per(page_size)
  end

  def page_parameter
    params[:page]
  end

  def page_number
    page_number = (page_parameter || 1).to_i
    page_number < 1 ? 1 : page_number
  end

  def results_offset
    result_offset = (page_parameter.to_i - 1) * page_size
    result_offset < 0 ? 0 : result_offset
  end

  def page_size
    #ToDo Hiding param to alter page size. Hardcode to 25 results per page?
    # page_size = (params[:pageSize])?(params[:pageSize].to_i):25
    # page_size = 1 if page_size < 1
    # page_size
    25
  end

  def calc_max_number_of_pages(total_results)
    return 1 if total_results <= page_size
    if total_results % page_size == 0
      total_results / page_size
    else
      total_results / page_size + 1
    end
  end

  def calc_kaminari_window_size(max_number_of_pages)
    p_number = page_number
    if p_number < 5
      9 - p_number
    elsif p_number > max_number_of_pages - 6
      9 - (max_number_of_pages - p_number)
    else
      4
    end
  end

end
