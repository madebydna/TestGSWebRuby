class CommunityScorecardsController < ApplicationController

  # TODO This breaks for Spanish
  before_filter :redirect_to_canonical_url
  before_filter :use_gs_bootstrap

  def show
    @collection = collection
    @table_fields = [
      # These data_type keys match with I18n keys to get the labels
      { data_type: :school_info, partial: :school_info },
      { data_type: :a_through_g, partial: :percent_value },
      { data_type: :graduation_rate, partial: :percent_value },
    ]

    set_mobile_dropdown_instance_var!
    set_subgroups_for_header!

    gon.pagename = 'GS:CommunityScorecard'
    @t_scope = 'innovate_public_schools'
    set_meta_tags(title: I18n.t("community_scorecards.show.#{@t_scope}.title"))
    gon.community_scorecard_params = default_params.merge(permitted_params)
  end

  protected

  def set_subgroups_for_header!
    #todo move into collection
    subgroups = subgroups_list.map do | subgroup |
      [
        CSC_t(subgroup),
        subgroup,
        { class: 'js-drawTable', data: { 'sort-breakdown' => subgroup } }
      ]
    end
    @subgroups_for_header = [subgroups, params[:sortBreakdown]]
  end

  def set_mobile_dropdown_instance_var!
    data_types = @table_fields.each_with_object([]) do |table_field, array|
      data_type = table_field[:data_type]
      data_type == :school_info || array << [
        CSC_t(data_type),
        data_type,
        { class: 'js-drawTable', data: { 'sort-by' => data_type } }
      ]
    end
    @data_type_dropdown_for_mobile = [data_types, params[:sortBy]]
  end

  def CSC_t(key)
    t("controllers.community_scorecards_controller.#{key}")
  end

  def default_params
    # TODO move into collection
    {
      collectionId: 15,
      gradeLevel: 'h',
      sortBy: 'graduation_rate',
      sortBreakdown: 'white',
      sortAscOrDesc: 'desc',
      offset: 0,
    }.merge({
        data_sets: @table_fields.map { |f| f[:data_type] }
      })
  end

  def permitted_params
    params.permit(:sortBy, :gradeLevel, :sortBreakdown, :sortAscOrDesc, :lang).symbolize_keys
  end

  def collection
    @_collection = Collection.find_by(id: params[:collection_id])
  end

  def subgroups_list
    #move to collection config
    [
      :all_students,
      :african_american,
      :asian,
      :filipino,
      :hispanic,
      :multiracial,
      :native_american_or_native_alaskan,
      :pacific_islander,
      :economically_disadvantaged,
      :limited_english_proficient
    ]
  end

  def canonical_path
    community_scorecard_path(
      collection_id: params[:collection_id],
      collection_name: collection.url_name,
    )
  end
end
