# This was taken from http://stackoverflow.com/questions/6354043/how-to-use-signal-blocking-in-ruby
class SignalHandler
  def initialize(signal)
    @interruptable = true
    @enqueued     = [ ]
    trap(signal) do
      if @interruptable
        puts 'Graceful shutdown...'
        puts 'Goodbye.'
        exit 0
      else
        @enqueued.push(signal)
      end
    end
  end

  # If this is called with a block then the block will be run with
  # the signal temporarily ignored. Without the block, we'll just set
  # the flag and the caller can call `allow_interruptions` themselves.
  def dont_interrupt
    @interruptable = false
    @enqueued     = [ ]
    if block_given?
      yield
      allow_interruptions
    end
  end

  def allow_interruptions
    @interruptable = true
    # Send the temporarily ignored signals to ourself
    # see http://www.ruby-doc.org/core/classes/Process.html#M001286
    @enqueued.each { |signal| Process.kill(signal, 0) }
  end
end