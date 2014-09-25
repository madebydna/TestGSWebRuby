class PyocController <  ApplicationController

  def print_pdf
    # render 'error/page_not_found', layout: 'error', status: 404
    respond_to do |format|
      format.html
      format.pdf do
        pdf = PrawnPdf.new(print_pdf_url)
        send_data pdf.render, filename: 'hello',
                  type: 'application/pdf',
                  disposition: 'inline' #loads pdf directly in browser window
      end
    end

    # render 'pyoc/print_pdf'

  end

end