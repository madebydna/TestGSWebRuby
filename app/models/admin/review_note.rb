class ReviewNote < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  db_magic :connection => :gs_schooldb

end