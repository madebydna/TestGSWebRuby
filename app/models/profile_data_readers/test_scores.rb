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
    #data(school)
    #puts "---------------test scores-#{rows.any?}-----"
    #if rows.any?
    #  TableData.new rows
    #end
    Hashie::Mash.new({rows: data(school)})
  end

  def prettify_data(school, table_data)
    table_data
  end

end