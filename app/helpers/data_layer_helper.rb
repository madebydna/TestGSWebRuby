module DataLayerHelper

  protected

  #executed in application controller to set the gon hash
  def set_data_layer_gon_hash!
    data_layer_gon_hash
  end

  #assign gon hash to gon.data_layer
  def data_layer_gon_hash
    @data_layer_gon_hash ||= (gon.data_layer_hash = {})
  end

end