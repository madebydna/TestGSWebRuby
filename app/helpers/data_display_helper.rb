module DataDisplayHelper
  protected

  def truncate_with_popup(text, options={})
    if options.key? :length
      if text.length >= options[:length]
        return render 'shared/truncated_text_popup', text: text, options: options
      else
        text
      end
    else
      raise "Please provide length for truncating #{text}"
    end
  end
end