class StackProfMiddleware < StackProf::Middleware
  def initialize(app, options = {})
    @app       = app
    @options   = options
    @num_reqs  = options[:save_every] || nil

    StackProfMiddleware.mode     = options[:mode] || :cpu
    StackProfMiddleware.interval = options[:interval] || 1000
    StackProfMiddleware.raw      = options[:raw]
    StackProfMiddleware.enabled  = options[:enabled]
    StackProfMiddleware.path     = options[:path] || 'tmp'
    at_exit{ StackProfMiddleware.save } if options[:save_at_exit]
  end

  def call(env)
    req = Rack::Request.new(env)
    enabled = StackProfMiddleware.enabled?(env) && ENV_GLOBAL['profiling_key'].present? && req.params['profiling'] == ENV_GLOBAL['profiling_key']
    StackProf.start(mode: StackProfMiddleware.mode, interval: StackProfMiddleware.interval, raw: StackProfMiddleware.raw) if enabled
    @app.call(env)
  ensure
    if enabled
      StackProf.stop
      if @num_reqs && (@num_reqs-=1) == 0
        @num_reqs = @options[:save_every]
        StackProfMiddleware.save
      end
    end
  end

  class << self
    attr_accessor :enabled, :mode, :interval, :raw, :path

    def enabled?(env)
      if enabled.respond_to?(:call)
        enabled.call(env)
      else
        enabled
      end
    end

    def save(filename = nil)
      if results = StackProf.results
        FileUtils.mkdir_p(StackProfMiddleware.path)
        filename ||= "stackprof-#{results[:mode]}-#{Process.pid}-#{Time.now.to_i}.dump"
        File.open(File.join(StackProfMiddleware.path, filename), 'wb') do |f|
          f.write Marshal.dump(results)
        end
        filename
      end
    end
  end
end
