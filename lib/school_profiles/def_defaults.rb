module SchoolProfiles
  module DefDefaults
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def default(default_value, *names)
        names.each do |name|
          self.def_default(name, default_value)
        end
      end

      def def_default(name, default_value)
        method_name = "#{name}_or_default"
        define_method(method_name) do
          r = self.send(name)
          return default_value if r.nil?
          return default_value if r.is_a?(String) && r.blank?
          return r
        end
      end
    end
  end
end
