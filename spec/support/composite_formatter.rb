class CompositeFormatter
  # This registers the notifications this formatter supports, and tells
  # us that this was written against the RSpec 3.x formatter API.
  RSpec::Core::Formatters.register self, :start, :example_group_started, :start_dump,
                            :example_started, :example_passed, :example_failed,
                            :example_pending, :dump_summary

  def initialize(output)
    formatter_classes = [
      RSpec::Core::Formatters::ProgressFormatter,
      RSpec::Core::Formatters::HtmlFormatter
    ]
    outputs = [STDOUT]
    outputs = outputs.fill(output, outputs.size..(formatter_classes.size-1))
    @outputs = outputs
    @formatters = formatter_classes.zip(outputs).map do |(formatter, o)|
      formatter.new(o)
    end
  end
  
  [:start, :example_group_started, :start_dump, :example_started, :example_passed,
   :example_failed, :example_pending, :dump_summary].each do |method|
    define_method(method) do |*args|
      @formatters.each do |formatter|
        formatter.send(method, *args) if formatter.respond_to?(method)
      end
    end
  end
end
