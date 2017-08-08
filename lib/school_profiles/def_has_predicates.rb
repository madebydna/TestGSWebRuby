module SchoolProfiles
  module DefHasPredicates
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def def_has_predicates(*names)
        names.each { |name| self.def_has_predicate(name) }
      end

      def def_has_predicate(name)
        method_name = "has_#{name}?"
        define_method(method_name) do
          r = self.send(name)
          return false if r.nil?
          return false if r.is_a?(String) && r.blank?
          true
        end
      end
    end
  end
end
