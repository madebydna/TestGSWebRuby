module Omni
  class Subject < ActiveRecord::Base
    db_magic connection: :omni

  end
end