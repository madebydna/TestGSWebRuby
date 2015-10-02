# This purposefully doesn't use Draper, as I don't think it should have
# access to the view, or be thought of as a view-model / presenter style
# decorator
class SchoolCacheDecorator
  include GradeLevelConcerns

  attr_reader :school, :cache_data

  def initialize(school, cache_data = {})
    @school = school
    @cache_data = cache_data
  end

  def method_missing(meth, *args)
    if @school.respond_to?(meth) 
      @school.send(meth, *args)
    else
      super
    end
  end

  def respond_to?(meth)
    @school.respond_to?(meth)
  end

  def zip
    @school.zipcode
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
