class CustomerLike < ActiveRecord::Base
  include BehaviorForModelsWithActiveField
  db_magic :connection => :gs_schooldb

  scope :active_cue_card_likes_for, ->(item_key) do
    where(product_id: 1, item_key: item_key, active: 1)
  end

end
