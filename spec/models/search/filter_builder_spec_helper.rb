module FilterBuilderSpecHelper

  def filter_elements(filters_hash)
    filters = []
    expect(filters_hash).to be_a Hash
    if filters_hash.has_key?(:filters)
      filters_hash[:filters].each do |_, inner_hash|
        filter_elements(inner_hash).each do |filter|
          filters << filter
        end
      end
    else
      filters << filters_hash
    end
    filters
  end

  def check_title_layers(filters_hash)
    if filters_hash.key?(:display_type) && filters_hash[:display_type] == :title
      return false unless filters_hash.key?(:name) && filters_hash.key?(:filters)
    end
    if filters_hash.key?(:filters)
      filters_hash[:filters].each do |key, inner_hash|
        check_title_layers(inner_hash)
      end
    end
  end

end
