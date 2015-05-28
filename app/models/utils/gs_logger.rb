class GSLogger

  WARN  = 'WARN'
  ERROR = 'ERROR'
  INFO  = 'INFO"'

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
      m << "RESCUE_LOCATION:#{binding.send(:caller).first}||OPT_MESSAGE||OPT_VARS"
      m.gsub!(/\n\t/, '')
      Rails.logger.error(m)
    end

    def log(level, tag, rescue_line, exception, opts = {})
      base_log = process_log(level, tag, rescue_line, exception)
      options  = process_opts(opts)

      log = (base_log + options).join('||').gsub(/\n|\t|\r/, '')
      log.prepend("\n").concat("\n")

      Rails.logger.error(log)
    end

    #make sure to keep the order of the logs consistent
    #ie GS||LEVEL||TAG||ERROR||TIME||ERROR_LOCATION||RESCUE_LOCATION||OPT_MESSAGE||OPT_VARS
    def process_log(level, tag, rescue_line, e)
      time            = Time.now
      error           = e.is_a?(Exception) ? "#{e.class} #{e.message}" : "No exception thrown"
      error_location  = e.is_a?(Exception) ? "#{e.backtrace.first}" : "No exception thrown"

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
