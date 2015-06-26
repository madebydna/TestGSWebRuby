module DataLayerConcerns
  extend ActiveSupport::Concern

  protected

  #executed in application controller to set the gon hash
  def set_data_layer_gon_hash!
    data_layer_gon_hash
  end

  #assign gon hash to gon.data_layer
  def data_layer_gon_hash
    @data_layer_gon_hash ||= (gon.data_layer_hash = {})
  end

  def add_user_info_to_gtm_data_layer
    if current_user
      data_layer_gon_hash['User ID'] = current_user.id
      if current_user.provisional_or_approved_osp_user?
        data_layer_gon_hash['GS User Type'] = 'OSP'
      else
        data_layer_gon_hash['GS User Type'] = 'regular'
      end
    end
  end

  def add_collection_id_to_gtm_data_layer
    if @hub
      data_layer_gon_hash['Collection ID'] = @hub.collection_id
    end
  end
end
