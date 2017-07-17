module SchoolProfiles
  module Components
    class ComponentGroup
      def to_hash
        results = components.select(&:has_data?).take(3).each_with_object({}) do |component, accum|
          accum[t(component.title)] = component.to_hash
        end
        overview ? overview.merge(results) : results
      end

      def overview
        nil
      end
    end
  end
end
