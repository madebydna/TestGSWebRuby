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

  def add_user_id_to_gtm_data_layer
    if current_user
      data_layer_gon_hash['User ID'] = current_user.id
    end
  end

end
