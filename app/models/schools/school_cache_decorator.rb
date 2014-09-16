# This purposefully doesn't use Draper, as I don't think it should have
# access to the view, or be thought of as a view-model / presenter style
# decorator
class SchoolCacheDecorator

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

  def fit_score
    0
  end

end