class PyocController <  ApplicationController

  def print_pdf
    # render 'error/page_not_found', layout: 'error', status: 404
    render 'pyoc/print_pdf'

  end

end