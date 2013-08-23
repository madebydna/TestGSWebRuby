class ResponseValue < ActiveRecord::Base
  attr_accessible :collection_id, :collection, :response_label, :response_value
  belongs_to :collection
end
