module MetricsCaching
  module CommonCachedMetricsMethods
    def metrics
      cache_data['metrics'] || {}
    end

    def decorated_metrics
      metrics.each_with_object({}) do |(data_type, array), accum|
        accum[data_type] =
          array.map do |h|
            Value.from_hash(h).tap {|dv| dv.data_type = data_type}
          end.extend(Value::CollectionMethods)
      end
    end

    def graduates_remediation
      @_graduates_remediation ||= begin
        all = decorated_metrics.slice(*CollegeReadinessConfig::GRADUATES_REMEDIATION)
        all.each do |key, array|
          if array.detect {|metric| metric.subject == "Any Subject" }
            array.reject! {|metric| metric.subject == "Composite Subject" }
          end
          array.each {|dv| dv.extend(GraduatesRemediationValue)}
        end
        all
      end
    end
  end
end