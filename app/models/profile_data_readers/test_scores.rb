class TestScores

  def key
    'ethnicity_data'
  end

  def initialize(category)
    @category = category
  end

  def data(school)
    school.test_scores
  end

  def table_data(school)
    data(school)
  end

  def prettify_data(school, table_data)
    table_data
  end

end