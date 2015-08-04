class GSLogger
  WARN  = 'WARN'
  ERROR = 'ERROR'
  INFO  = 'INFO'

  TAGS = Hash.new('MISC').merge({
    osp: 'OSP',
    reviews: 'REVIEWS'
  })

  class << self

    [WARN, ERROR, INFO].each do |constant|
      define_method(constant.downcase) do |tag, exception = nil, opts = {} |
        begin
          log(constant, tag, binding.send(:caller).first, exception, opts)
        rescue => e
          log_own_failure(e)
        end
      end
    end

    def log_own_failure(e)
      m = "GS||ERROR||GSLogger||#{e.class} #{e.message}||#{Time.now}||ERROR_LOCATION:#{e.backtrace.first}||"
      m << "RESCUE_LOCATION:#{binding.send(:caller).first}||REQUEST_URL||OPT_MESSAGE||OPT_VARS"
      m.gsub!(/\n|\t/, '')
      Rails.logger.error(m)
    end

    def log(level, tag, rescue_line, exception, opts = {})
      base_log = process_log(level, TAGS[tag], rescue_line, exception)
      options  = process_opts(opts)

      log = (base_log + options).join('||').gsub(/\n|\t|\r/, '')
      log.prepend("\n").concat("\n")

      Rails.logger.error(log)
    end

    #make sure to keep the order of the logs consistent
    #ie GS||LEVEL||TAG||ERROR||TIME||ERROR_LOCATION||RESCUE_LOCATION||REQUEST_URL||OPT_MESSAGE||OPT_VARS
    def process_log(level, tag, rescue_line, e)
      time            = Time.now
      error           = e.is_a?(Exception) ? "#{e.class} #{e.message}" : "No exception thrown"
      error_location  = e.is_a?(Exception) ? "#{e.backtrace.first}" : "No exception thrown"
      request_url     = get_request_url || "REQUEST_URL"

      [
        "GS",
        "#{level}",
        "#{tag}",
        "#{error}",
        "#{time}",
        "ERROR_LOCATION:#{error_location}",
        "RESCUE_LOCATION:#{rescue_line}",
        request_url
      ]
    end

    #beware of possible segmentation fault issue with binding.of_caller method
    #https://github.com/banister/binding_of_caller/issues/14
    #Haven't been able to reproduce it. Probably ok for now, but worth keeping an eye on
    def get_request_url
      frame_count = binding.frame_count - 1 #excluding current frame
      frame_count.times do | n |
        url = binding.of_caller(n).eval('try(:request).try(:original_url)')
        url.present? ? (return "REQUEST_URL:#{url}") : next
      end
      nil
    end

    def process_opts(opts = {})
      vars = vars_to_string(opts[:vars])
      message = opts[:message].is_a?(String) ? opts[:message] : ''

      [
        (message.present? ? "OPT_MESSAGE:#{message}" : "OPT_MESSAGE"),
        (vars.present? ? "OPT_VARS:#{vars}" : "OPT_VARS")
      ]
    end

    def vars_to_string(vars = {})
      return '' unless vars.is_a? Hash
      vars.map do |key, value|
        "#{key.to_s}=#{value.to_s}"
      end.join(',')
    end

  end
end
