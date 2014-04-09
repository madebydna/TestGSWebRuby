require 'zeus/rails'

class ZeusPlan < Zeus::Rails

  def spec(argv=ARGV)
    # disable autorun in case the user left it in spec_helper.rb
    RSpec::Core::Runner.disable_autorun!
    exit RSpec::Core::Runner.run(argv)
  end

end

Zeus.plan = ZeusPlan.new
