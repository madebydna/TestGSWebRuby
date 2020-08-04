# frozen_string_literal: true

module Components
  class ComponentGroup
    def active_components
      components.select(&:has_data?).take(3)
    end

    def to_hash
      results = active_components.each_with_object([]) do |component, accum|
        accum << component.to_hash.merge(title: t(component.title), anchor: component.title)
      end
      overview ? [overview].concat(results) : results
    end

    def overview
      nil
    end
  end
end