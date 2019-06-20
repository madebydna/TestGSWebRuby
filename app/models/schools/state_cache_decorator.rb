class StateCacheDecorator

  attr_reader :state, :cache_data

  def initialize(state, cache_data = {})
    @state = state
    @cache_data = cache_data
  end

  # def method_missing(meth, *args)
  #   if @district.respond_to?(meth)
  #     @district.send(meth, *args)
  #   else
  #     super
  #   end
  # end

  # def respond_to?(meth, include_private=false)
  #   @district.respond_to?(meth, include_private)
  # end

  # def zip
  #   @district.zipcode
  # end

  # def merged_data
  #   @_merged_data ||= begin
  #     @cache_data.each_with_object({}) do |(_, data), hash|
  #       data.each do |key, values|
  #         hash[key.to_sym] = []
  #         values.each { |v| hash[key.to_sym] << v.symbolize_keys }
  #       end
  #     end
  #   end
  # end
end
