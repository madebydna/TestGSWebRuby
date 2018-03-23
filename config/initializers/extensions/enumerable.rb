# frozen_string_literal: true

module Enumerable

  if instance_methods.include?(:average)
    msg = 'average already defined in Enumerable, will not override'
    puts msg
    GSLogger.error(:MISC, nil, message: msg)
  else
    def average(*args, &block)
      sum(*args, &block).to_f / size
    end
  end

  if instance_methods.include?(:weighted_average)
    msg = 'weighted_average already defined in Enumerable, will not override'
    puts msg
    GSLogger.error(:MISC, nil, message: msg)
  else
    def weighted_average(sum_of_weights, *args, &block)
      sum(*args, &block).to_f / sum_of_weights
    end
  end

end
