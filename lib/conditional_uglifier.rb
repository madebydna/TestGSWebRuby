class ConditionalUglifier < Uglifier
  def compress(source)
    if source =~ /^\/\/= skip_minification/
      return source
    else
      super(source)
    end
  end
end
