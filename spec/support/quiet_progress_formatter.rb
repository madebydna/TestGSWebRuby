class QuietProgressFormatter < RSpec::Core::Formatters::ProgressFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed, :dump_pending
  
  def example_passed(_notification)
  end

  def example_pending(_notification)
  end

  def example_failed(_notification)
  end

  def dump_pending(_notification)
    # nope
  end

end
