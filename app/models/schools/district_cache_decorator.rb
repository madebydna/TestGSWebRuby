# This purposefully doesn't use Draper, as I don't think it should have
# access to the view, or be thought of as a view-model / presenter style
# decorator
class DistrictCacheDecorator
  include GradeLevelConcerns

  attr_reader :district, :cache_data

  def initialize(district, cache_data = {})
    @district = district
    @cache_data = cache_data
  end

  def method_missing(meth, *args)
    if @district.respond_to?(meth)
      @district.send(meth, *args)
    else
      super
    end
  end

  def respond_to?(meth)
    @district.respond_to?(meth)
  end

  def zip
    @district.zipcode
  end

  def merged_data
    @_merged_data ||= begin
      @cache_data.each_with_object({}) do |(_, data), hash|
        data.each do |key, values|
          hash[key.to_sym] = []
          values.each { |v| hash[key.to_sym] << v.symbolize_keys }
        end
      end
    end
  end
end
