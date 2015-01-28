require 'spec_helper'
require 'libs/data_loading/shared_examples_for_updates'

describe EspResponseLoading::Update do

  required_update_keys = [:entity_type, :entity_id, :entity_state, :value, :member_id]

  it_behaves_like 'an update', EspResponseLoading::Update, required_update_keys


end