module SchoolProfiles
  module Components
    class ComponentGroup
      def to_hash
        results = components.select(&:has_data?).take(3).each_with_object([]) do |component, accum|
          accum << component.to_hash.merge(title: t(component.title), anchor: component.title)
        end
        overview ? [overview].concat(results) : results
      end

      def overview
        nil
      end
    end
  end
end
