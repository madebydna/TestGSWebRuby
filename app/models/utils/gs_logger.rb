class GSLogger

  WARN  = 'WARN'
  ERROR = 'ERROR'
  INFO  = 'INFO"'

  class << self

    [WARN, ERROR, INFO].each do |constant|
      define_method(constant.downcase) do |tag, exception, opts = {} |
        log(constant, tag, binding.send(:caller).first, exception, opts)
      end
    end

    def log(level, tag, rescue_line, exception, opts = {})
      base_log = process_log(level, tag, rescue_line, exception)
      options  = process_opts(opts)

      log = (base_log + options).join('||').gsub(/\n\t/, '')
      log.prepend("\n").concat("\n")

      Rails.logger.error(log)
    end

    #make sure to keep the order of the logs consistent
    #ie GS||LEVEL||TAG||ERROR||TIME||ERROR_LOCATION||RESCUE_LOCATION||OPT_MESSAGE||OPT_VARS
    def process_log(level, tag, rescue_line, exception)
      time            = Time.now
      error           = "#{exception.class} #{exception.message}"
      error_location  = "#{exception.backtrace.first}"

      [
        "GS",
        "#{level}",
        "#{tag}",
        "#{error}",
        "#{time}",
        "ERROR_LOCATION:#{error_location}",
        "RESCUE_LOCATION:#{rescue_line}"
      ]
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
