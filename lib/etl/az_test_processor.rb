require_relative "test_processor"


class AZTestProcessor < GS::ETL::TestProcessor

  def build_graph
      dist_source = CsvSource.new(input_filename("aims_dist_sci_2015.txt"), col_sep: "\t", max: @options[:max])
      schl_source = CsvSource.new(input_filename("aims_schl_sci_2015.txt"), col_sep: "\t", max: @options[:max])
      state_source = CsvSource.new(input_filename("aims_state_sci_2015.txt"), col_sep: "\t", max: @options[:max])

      @sources = [dist_source,schl_source,state_source]

      key_map = {
        'X' => 'All',
        'A' => 'Asian',
        'B' => 'African American',
        'H' => 'Hispanic or Latino',
        'I' => 'Native American',
        'W' => 'White',
        'L' => 'Limited English Proficient',
        'T' => 'Economically Disadvantaged',
        'S' => 'Students With Disabilities',
        'M' => 'MALE',
        'F' => 'FEMALE',
        'G' => 'MIGRANT'
      }
      union_steps(dist_source,schl_source,state_source)
      .transform("Mapping type to breakdown description",
        HashLookup, :type, key_map)
      .transform("Renaming fields",
        MultiFieldRenamer,
        {
          fiscalyear: :year,
          distcode: :district_id,
          distname: :district_name,
          schlname: :school_name,
          schlcode: :school_id,
          type: :breakdown,
          pctpass: :value_float
        })
      .transform('', WithBlock) do |row|
        puts row
        nil
      end
  end

  def run
    build_graph
    @sources.each { |source| source.run }
  end
end

AZTestProcessor.new(ARGV[0], max: ARGV[1].to_i).run
