module DataLayerConcerns
  extend ActiveSupport::Concern

  DATALAYER_COOKIE_NAME = 'GATracking'

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

  def trigger_event(category, action, label=nil, value=nil, non_interactive=false)
    events = read_cookie_value(:"#{DATALAYER_COOKIE_NAME}",'events') || []
    events += [{category: category, action: action, label: label, value: value, non_interactive: non_interactive}]
    write_cookie_value(:"#{DATALAYER_COOKIE_NAME}", events, 'events')
  end
end
