module CachePopulator
    class PopulatorError < StandardError; end
    
    class Base
        include ActiveModel::Validations
        CACHE_KEYS = []

        attr_accessor :states, :optional_ids, :cache_keys, :log
        def initialize(values:, cache_keys:)
            states_raw, @optional_ids = values.try(:split, ':')
            @states = states_raw.try(:split, /,\s?/)
            @cache_keys = cache_keys.try(:split, /,\s?/)
            @log = ScriptLogger.record_log_instance(log_script_name, log_params)
        end

        validates :states, presence: true
        validates :cache_keys, presence: true
        validate :check_for_valid_cache_keys
        validate :check_for_valid_states

        def run_with_validation
            if valid?
                states_to_cache.each do |state|
                    puts "Working on state: #{state}"
                    keys_to_cache.each do |cache_key|
                        puts "... doing cache key: #{cache_key}"
                        yield state, cache_key
                    end
                end
            else
                log.update(
                    output: print_errors,
                    succeeded: 0,
                    end: Time.now.utc
                )
                raise PopulatorError.new("#{self.class} cache failure: #{print_errors}")
            end
        end


        def states_to_cache
            states.first == 'all' ? States.abbreviations : states
        end

        def keys_to_cache
            cache_keys.first == 'all' ? self.class::CACHE_KEYS : cache_keys
        end

        def print_errors
            errors.map { |k, v| "#{k} #{v}"}.join("; ")
        end


        private
        def check_for_valid_cache_keys
            unless cache_keys.present? && 
                (cache_keys.first == 'all' || cache_keys.all? {|key| self.class::CACHE_KEYS.include?(key)})
                errors[:cache_keys] << "must have the value 'all' or be a list of valid cache keys"
                log.update(
                    output: print_errors,
                    succeeded: 0
                )
            end
        end

        # value of 'values' is usually a list of states, but can be different based on subclass
        def check_for_valid_states
            unless states.present? && 
                (states.first == 'all' || states.all? {|key| States.abbreviations.include?(key)})
                errors.add(:states, "must have the value 'all' or be a list of valid states")
                log.update(
                    output: print_errors,
                    succeeded: 0,
                    end: Time.now.utc
                )
            end
        end

        def parse_optional_ids
            return unless optional_ids.present?
            if optional_ids =~ /^\d+(,\s?\d+)*$/
                { id: optional_ids.split(/,\s?/) }
            else
                # custom sql snippet
                optional_ids
            end
        end

        %w(log_script_name log_params run).each do |method_name|
            define_method(method_name) do
                raise NotImplementedError.new("##{method_name} must be defined in the cacher class")
            end 
        end
    end

end