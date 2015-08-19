class CommunityScorecardsController < ApplicationController

  before_filter :use_gs_bootstrap

  def show
    @collection = Collection.find(15)
    @table_fields = [
      # These data_type keys match with I18n keys to get the labels
      { data_type: :school_info, partial: :school_info },
      { data_type: :a_through_g, partial: :percent_value },
      { data_type: :graduation_rate, partial: :percent_value },
    ]

    #todo move into collection
    @subgroups_for_header = SchoolDataHash::SUBGROUP_MAP.to_a
    @subgroups_for_header.each { | subgroup_array | subgroup_array << { class: 'js-drawTable' } }

    gon.scorecard_data_types = @table_fields.map { |f| f[:data_type] }
    gon.pagename = 'GS:CommunityScorecard'
  end
end
