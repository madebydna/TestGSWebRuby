class CommunitySpotlightsController < ApplicationController

  # TODO This breaks for Spanish
  before_filter :redirect_to_canonical_url
  before_filter :use_gs_bootstrap

  def show
    @collection = collection
    @t_scope = "collection_id_#{collection.id}"
    @table_fields = collection.scorecard_fields

    set_mobile_dropdown_instance_var!
    set_subgroups_for_header!
    set_grade_levels_for_header!
    gon.community_scorecard_params = default_params.merge(permitted_params)

    set_tracking_and_meta_info
  end

  protected

  def set_subgroups_for_header!
    subgroups = subgroups_list.map do | subgroup |
      [
        CSC_t(subgroup),
        subgroup,
        { class: 'js-drawTable', data: { 'sort-breakdown' => subgroup } }
      ]
    end
    config_value = default_params[:sortBreakdown]
    @subgroups_for_header = [subgroups, params[:sortBreakdown] || config_value]
  end

  def set_grade_levels_for_header!
    grade_levels = ['all_grade_levels', 'elementary', 'middle', 'high'].map do | grade_level |
      [
        CSC_t(grade_level),
        grade_level[0],
        { class: 'js-drawTable', data: { 'grade-level' => grade_level[0] } }
      ]
    end
    config_value = default_params[:gradeLevel]
    @grade_levels_for_header = [grade_levels, params[:gradeLevel] || config_value]
  end

  def set_mobile_dropdown_instance_var!
    data_types = @table_fields.each_with_object([]) do |table_field, array|
      data_type = table_field[:data_type]
      unless data_type.to_s == 'school_info'
        array << [
          CSC_t(data_type),
          data_type,
          { class: 'js-drawTable', data: { 'sort-by' => data_type } }
        ]
      end
    end
    config_value = default_params[:sortBy]
    @data_type_dropdown_for_mobile = [data_types, params[:sortBy] || config_value]
  end

  def CSC_t(key)
    t("controllers.community_spotlights_controller.#{key}")
  end

  def default_params
    collection.scorecard_params.merge(
      data_sets: @table_fields.map { |f| f[:data_type] },
      collectionId: collection.id,
    )
  end

  def permitted_params
    params.permit(:sortBy, :gradeLevel, :sortBreakdown, :sortAscOrDesc, :lang).symbolize_keys
  end

  def collection
    @_collection ||= Collection.find_by(id: params[:collection_id])
  end

  def subgroups_list
    collection.scorecard_subgroups_list
  end

  def canonical_path
    community_spotlight_path(
      collection_id: params[:collection_id],
      collection_name: collection.url_name,
    )
  end

  def set_tracking_and_meta_info
    page_name = 'GS:CommunitySpotlight'
    gon.pagename = page_name
    data_layer_gon_hash[DataLayerConcerns::PAGE_NAME] = page_name
    data_layer_gon_hash[DataLayerConcerns::COLLECTION_ID] = collection.id
    set_meta_tags(title: I18n.t("community_spotlights.show.#{@t_scope}.title"))
  end
end
