class RowExploderSource
  def initialize(normalizer_instance, source_klass, *args)
    @normalizer = normalizer_instance
    @source = source_klass.new(*args)
  end

  def each
    @source.each do |row|
      @normalizer.process(row) do |subrow|
        yield subrow
      end
    end
  end
end


