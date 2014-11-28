require_relative 'benchmarker.rb'
class FitSortBenchmark < Benchmarker
  include FitScoreConcerns
  include SortingConcerns

  PARAMS_HASH = {
      # Currently doing 15 filters
      # TODO Maybe add a way to choose how many filters
      transportation: 'provided_transit',
      beforeAfterCare: %w(before after),
      dress_code: 'uniform',
      class_offerings: %w(ap visual_media_arts german),
      boys_sports: %w(soccer basketball),
      girls_sports: 'volleyball',
      school_focus: %w(career_tech online science_tech waldorf german)
  }

  SERVICE_OPTIONS = {
      # About 2000 schools within 60 miles of Speedway, IN
      number_of_results: 2000,
      offset: 0,
      sort: :rating_desc,
      lat: '39.7924104',
      lon: '-86.2514126',
      radius: '60',
      state: 'in'
  }

  def initialize
    @max_num_schools = 2000
    @interval = 100
    @filter_builder = FilterBuilder.new('IN')

    @schools = SchoolSearchService.by_location(SERVICE_OPTIONS)[:results]
    @file_name = 'fit_sort_benchmark_results.csv'
  end

  def start_benchmark!
    methods_to_benchmark = []
    (@max_num_schools/@interval).times.map do | i |
      school_count = (i + 1) * @interval
      schools_to_sort = @schools[0..(school_count - 1)]
      methods_to_benchmark << { name: schools_to_sort.size,
                                call: Proc.new {setup_and_sort_fit_scores(schools_to_sort)} }
    end
    time_process!(methods_to_benchmark)
  end

  def setup_and_sort_fit_scores(schools)
    results = schools.clone
    results.each do |result|
      result.calculate_fit_score!(PARAMS_HASH)
      unless result.fit_score_breakdown.nil?
        result.update_breakdown_labels! @filter_builder.filter_display_map
        result.sort_breakdown_by_match_status!
      end
    end
    sort_by_fit(results)
  end

end

FitSortBenchmark.new.start_benchmark!
