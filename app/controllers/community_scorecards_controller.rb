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

    @data_type_dropdown_for_mobile = @table_fields.each_with_object([]) do |table_field, array|
      data_type = table_field[:data_type]
      data_type == :school_info || array << [
        CSC_t(data_type),
        data_type,
        { class: 'js-drawTable', data: { 'sort-by' => data_type } }
      ]
    end

    #todo move into collection
    @subgroups_for_header = SchoolDataHash::SUBGROUP_MAP.keys.map do | subgroup |
      [
        CSC_t(subgroup),
        subgroup,
        { class: 'js-drawTable', data: { 'sort-breakdown' => subgroup } }
      ]
    end

    gon.scorecard_data_types = @table_fields.map { |f| f[:data_type] }
    gon.pagename = 'GS:CommunityScorecard'
  end

  def CSC_t(key)
    t("controllers.community_scorecards_controller.#{key}")
  end
end
