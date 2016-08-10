module TrailingSlashConcerns

  protected

  def with_trailing_slash(string)
    if string[-1] == '/'
      string
    else
      string + '/'
    end
  end

end

